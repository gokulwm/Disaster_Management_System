import 'dart:async';
import 'dart:convert';
import 'package:disaster_link/data/services/connectivity_service.dart';
import 'package:disaster_link/data/datasources/local_db_datasource.dart';
import 'package:disaster_link/data/datasources/supabase_datasource.dart';

import 'package:disaster_link/data/models/marker.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  StreamSubscription? _connectivitySubscription;

  void initialize() {
    _connectivitySubscription = ConnectivityService().onConnectivityChanged.listen((status) {
      if (status == ConnectivityStatus.online) {
        _syncOfflineItems();
      }
    });
  }

  Future<void> _syncOfflineItems() async {
    try {
      final items = await LocalDbDatasource().getUnsyncedItems();
      for (var item in items) {
        final id = item['id'] as String;
        final type = item['type'] as String;
        final jsonData = jsonDecode(item['json_data'] as String) as Map<String, dynamic>;

        try {
          if (type == 'help_request') {
            await SupabaseDatasource().submitHelpRequest(
              id: jsonData['id'] as String,
              helpType: jsonData['help_type'] as String,
              lat: (jsonData['lat'] as num).toDouble(),
              lng: (jsonData['lng'] as num).toDouble(),
              requesterName: jsonData['requester_name'] as String,
              description: jsonData['description'] as String,
              requestToken: jsonData['request_token'] as String,
              deviceFingerprint: jsonData['device_fingerprint'] as String,
            );
          } else if (type == 'marker') {
            await SupabaseDatasource().insertMarker(
              MarkerModel.fromJson(jsonData),
            );
          }
          
          await LocalDbDatasource().markAsSynced(id);
        } catch (e) {
          // If error is unique constraint violation (already synced), mark as synced anyway
          if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
            await LocalDbDatasource().markAsSynced(id);
          }
        }
      }
      
      await LocalDbDatasource().deleteSynced();
    } catch (e) {
      // Sync failed
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
