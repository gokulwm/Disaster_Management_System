import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:disaster_link/data/datasources/supabase_datasource.dart';
import 'package:disaster_link/data/datasources/local_db_datasource.dart';
import 'package:disaster_link/data/datasources/bt_datasource.dart';
import 'package:disaster_link/data/services/connectivity_service.dart';
import 'package:disaster_link/data/models/help_request_detail.dart';
import 'package:disaster_link/core/utils/device_fingerprint.dart';

/// Repository that abstracts help request data access.
///
/// Online → Supabase RPC functions.
/// Offline → SQLite queue + Bluetooth relay.
class HelpRequestRepository {
  final SupabaseDatasource _supabase = SupabaseDatasource();
  final LocalDbDatasource _localDb = LocalDbDatasource();
  final BtDatasource _bt = BtDatasource();
  final ConnectivityService _connectivity = ConnectivityService();

  /// Submit a help request. Returns the request token (UUID).
  ///
  /// Online → calls `submit_help_request()` RPC atomically.
  /// Offline → saves to SQLite queue + Bluetooth relay.
  Future<String> submitRequest({
    required String name,
    required String helpType,
    required double lat,
    required double lng,
    required String description,
  }) async {
    final id = const Uuid().v4();
    final requestToken = const Uuid().v4();
    final deviceFp = await DeviceFingerprint.getFingerprint();

    final status = await _connectivity.checkConnectivity();

    if (status == ConnectivityStatus.online) {
      await _supabase.submitHelpRequest(
        id: id,
        helpType: helpType,
        lat: lat,
        lng: lng,
        requesterName: name,
        description: description,
        requestToken: requestToken,
        deviceFingerprint: deviceFp,
      );
    } else {
      // Save to local queue for later sync
      final requestObj = {
        'id': id,
        'help_type': helpType,
        'lat': lat,
        'lng': lng,
        'requester_name': name,
        'description': description,
        'request_token': requestToken,
        'device_fingerprint': deviceFp,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      await _localDb.insertToQueue(id, 'help_request', jsonEncode(requestObj));

      // Relay via Bluetooth if available
      try {
        final btPayload = await _bt.preparePayload(id, requestObj);
        await _bt.relayPayload(btPayload);
      } catch (_) {
        // BT relay is best-effort
      }
    }

    return requestToken;
  }

  /// Seeker: get own request status via token (no login needed).
  Future<HelpRequestDetail?> getMyRequest(String token) async {
    return await _supabase.getMyRequest(token);
  }

  /// Volunteer: get pending help requests within default radius.
  Future<List<HelpRequestDetail>> getPendingRequests(
    double lat,
    double lng, {
    int radiusM = 5000,
  }) async {
    return await _supabase.getPendingRequestsForVolunteer(
      lat,
      lng,
      radiusM: radiusM,
    );
  }

  /// Volunteer: accept a pending request. Returns false if already taken.
  Future<bool> acceptRequest(String requestId) async {
    return await _supabase.acceptRequest(requestId);
  }

  /// Realtime subscription to help request changes.
  Stream<List<Map<String, dynamic>>> subscribeToRequests() {
    return _supabase.subscribeToHelpRequests();
  }
}
