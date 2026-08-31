import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum HelpRequestStatus { pending, accepted, resolved }
enum HelpType { food, medical, rescue, shelter, other }

class HelpRequest extends Equatable {
  final String id;
  final HelpType helpType;
  final LatLng locationCoarse;
  final HelpRequestStatus status;
  final String? acceptedBy;
  final String requestToken;
  final String deviceFingerprint;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const HelpRequest({
    required this.id,
    required this.helpType,
    required this.locationCoarse,
    required this.status,
    this.acceptedBy,
    required this.requestToken,
    required this.deviceFingerprint,
    required this.createdAt,
    this.syncedAt,
  });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    return HelpRequest(
      id: json['id'],
      helpType: HelpType.values.firstWhere((e) => e.toString() == 'HelpType.${json['helpType']}'),
      locationCoarse: LatLng(json['latCoarse'], json['lngCoarse']),
      status: HelpRequestStatus.values.firstWhere((e) => e.toString() == 'HelpRequestStatus.${json['status']}'),
      acceptedBy: json['acceptedBy'],
      requestToken: json['requestToken'],
      deviceFingerprint: json['deviceFingerprint'],
      createdAt: DateTime.parse(json['createdAt']),
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'helpType': helpType.toString().split('.').last,
      'latCoarse': locationCoarse.latitude,
      'lngCoarse': locationCoarse.longitude,
      'status': status.toString().split('.').last,
      'acceptedBy': acceptedBy,
      'requestToken': requestToken,
      'deviceFingerprint': deviceFingerprint,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  HelpRequest copyWith({
    String? id,
    HelpType? helpType,
    LatLng? locationCoarse,
    HelpRequestStatus? status,
    String? acceptedBy,
    String? requestToken,
    String? deviceFingerprint,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      helpType: helpType ?? this.helpType,
      locationCoarse: locationCoarse ?? this.locationCoarse,
      status: status ?? this.status,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      requestToken: requestToken ?? this.requestToken,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  List<Object?> get props => [id, helpType, locationCoarse, status, acceptedBy, requestToken, deviceFingerprint, createdAt, syncedAt];
}
