import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disaster_link/data/models/volunteer_profile.dart';
import 'package:disaster_link/data/models/marker.dart' as app_marker;
import 'package:disaster_link/data/models/help_request_detail.dart';

/// Centralized Supabase datasource.
///
/// All RPC function names and parameter names match the SQL schema in
/// `supabase_schema.sql`. Table names: `volunteer_profiles`, `markers`,
/// `help_requests`, `help_request_private`.
class SupabaseDatasource {
  static final SupabaseDatasource _instance = SupabaseDatasource._internal();
  factory SupabaseDatasource() => _instance;
  SupabaseDatasource._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════════════

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Check if the current session has a valid, non-expired JWT.
  bool hasValidSession() {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
        .isAfter(DateTime.now());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VOLUNTEER PROFILES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch the current user's volunteer profile.
  Future<VolunteerProfile?> getVolunteerProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    final res = await _client
        .from('volunteer_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (res == null) return null;
    return VolunteerProfile.fromJson(res);
  }

  /// Create a volunteer profile for the current auth user (called on signup).
  Future<void> createVolunteerProfile({
    required String fullName,
    String? phone,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('Not authenticated');

    await _client.from('volunteer_profiles').insert({
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'is_verified': false,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARKERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch markers within [radiusM] meters of the given coordinates.
  /// Uses PostGIS ST_DWithin on the server.
  Future<List<app_marker.MarkerModel>> fetchNearbyMarkers(
    double lat,
    double lng,
    double radiusM,
  ) async {
    // Direct table query with PostGIS — RLS allows public read
    final res = await _client.rpc('get_nearby_markers', params: {
      'v_lat': lat,
      'v_lng': lng,
      'v_radius_m': radiusM.toInt(),
    });

    final list = List<Map<String, dynamic>>.from(res ?? []);
    return list.map((m) => app_marker.MarkerModel.fromJson(m)).toList();
  }

  /// Insert a new marker (requires verified volunteer auth).
  Future<void> insertMarker(app_marker.MarkerModel marker) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('Not authenticated');

    await _client.from('markers').insert({
      'type': marker.type.name,
      'location': 'POINT(${marker.location.longitude} ${marker.location.latitude})',
      'title': marker.title,
      'description': marker.description,
      'created_by': user.id,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELP REQUESTS — via SECURITY DEFINER RPC functions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submit a help request via the atomic `submit_help_request()` function.
  /// This writes to both `help_requests` and `help_request_private` atomically.
  Future<void> submitHelpRequest({
    required String id,
    required String helpType,
    required double lat,
    required double lng,
    required String requesterName,
    required String description,
    required String requestToken,
    required String deviceFingerprint,
  }) async {
    await _client.rpc('submit_help_request', params: {
      'p_id': id,
      'p_help_type': helpType,
      'p_lat': lat,
      'p_lng': lng,
      'p_requester_name': requesterName,
      'p_description': description,
      'p_request_token': requestToken,
      'p_device_fingerprint': deviceFingerprint,
    });
  }

  /// Seeker: get own request status via token (no login required).
  Future<HelpRequestDetail?> getMyRequest(String token) async {
    final res = await _client.rpc('get_my_request', params: {
      'p_token': token,
    });

    final list = List<Map<String, dynamic>>.from(res ?? []);
    if (list.isEmpty) return null;
    return HelpRequestDetail.fromJson(list.first);
  }

  /// Volunteer: get pending requests within radius.
  /// Calls `get_pending_requests_for_volunteer()` which enforces is_verified.
  Future<List<HelpRequestDetail>> getPendingRequestsForVolunteer(
    double lat,
    double lng, {
    int radiusM = 5000,
  }) async {
    final res = await _client.rpc('get_pending_requests_for_volunteer', params: {
      'v_lat': lat,
      'v_lng': lng,
      'v_radius_m': radiusM,
    });

    final list = List<Map<String, dynamic>>.from(res ?? []);
    return list.map((m) => HelpRequestDetail.fromJson(m)).toList();
  }

  /// Volunteer: get full details of a request they have accepted.
  Future<HelpRequestDetail?> getAcceptedRequest(String requestId) async {
    final res = await _client.rpc('get_accepted_request', params: {
      'p_request_id': requestId,
    });

    final list = List<Map<String, dynamic>>.from(res ?? []);
    if (list.isEmpty) return null;
    return HelpRequestDetail.fromJson(list.first);
  }

  /// Volunteer: accept a pending help request (atomic race-condition safe).
  Future<bool> acceptRequest(String requestId) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('Not authenticated');

    final result = await _client
        .from('help_requests')
        .update({
          'status': 'accepted',
          'accepted_by': user.id,
        })
        .eq('id', requestId)
        .eq('status', 'pending')
        .select()
        .maybeSingle();

    // If result is null, another volunteer already accepted
    return result != null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subscribe to all help request changes (status updates, new requests).
  Stream<List<Map<String, dynamic>>> subscribeToHelpRequests() {
    return _client
        .from('help_requests')
        .stream(primaryKey: ['id'])
        .order('created_at');
  }

  /// Subscribe to all marker changes (new markers, deactivations).
  Stream<List<Map<String, dynamic>>> subscribeToMarkers() {
    return _client
        .from('markers')
        .stream(primaryKey: ['id'])
        .order('created_at');
  }
}
