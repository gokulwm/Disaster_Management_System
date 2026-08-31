import 'dart:convert';
import 'package:disaster_link/data/datasources/supabase_datasource.dart';
import 'package:disaster_link/data/datasources/local_db_datasource.dart';
import 'package:disaster_link/data/services/connectivity_service.dart';
import 'package:disaster_link/data/models/marker.dart';

/// Repository that abstracts marker data access.
///
/// Online → Supabase PostGIS queries.
/// Offline → reads from local cache (if available).
class MarkerRepository {
  final SupabaseDatasource _supabase = SupabaseDatasource();
  final LocalDbDatasource _localDb = LocalDbDatasource();
  final ConnectivityService _connectivity = ConnectivityService();

  /// Fetch markers within default radius of given coordinates.
  Future<List<MarkerModel>> fetchNearbyMarkers(
    double lat,
    double lng, {
    double radiusM = 5000,
  }) async {
    final status = await _connectivity.checkConnectivity();
    if (status == ConnectivityStatus.online) {
      return await _supabase.fetchNearbyMarkers(lat, lng, radiusM);
    }
    // Offline: return empty for now — could be enhanced with local cache
    return [];
  }

  /// Add a new marker. Saves to Supabase if online, local queue if offline.
  Future<void> addMarker(MarkerModel marker) async {
    final status = await _connectivity.checkConnectivity();
    if (status == ConnectivityStatus.online) {
      await _supabase.insertMarker(marker);
    } else {
      await _localDb.insertToQueue(
        marker.id,
        'marker',
        jsonEncode(marker.toJson()),
      );
    }
  }

  /// Realtime subscription to marker changes.
  Stream<List<MarkerModel>> subscribeToMarkers() {
    return _supabase.subscribeToMarkers().map(
      (list) => list.map((m) => MarkerModel.fromJson(m)).toList(),
    );
  }
}
