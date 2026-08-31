import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/data/models/help_request.dart';

class HelpRequestDetail extends Equatable {
  final String id;
  final HelpType helpType;
  final LatLng locationCoarse;
  final HelpRequestStatus status;
  final String? acceptedBy;
  final String requestToken;
  final String deviceFingerprint;
  final DateTime createdAt;
  final DateTime? syncedAt;
  
  final String requesterName;
  final LatLng location;
  final String description;
  final double? distMeters;

  const HelpRequestDetail({
    required this.id,
    required this.helpType,
    required this.locationCoarse,
    required this.status,
    this.acceptedBy,
    required this.requestToken,
    required this.deviceFingerprint,
    required this.createdAt,
    this.syncedAt,
    required this.requesterName,
    required this.location,
    required this.description,
    this.distMeters,
  });

  factory HelpRequestDetail.fromJson(Map<String, dynamic> json) {
    return HelpRequestDetail(
      id: json['id'],
      helpType: HelpType.values.firstWhere((e) => e.toString() == 'HelpType.${json['helpType']}'),
      locationCoarse: LatLng(json['latCoarse'], json['lngCoarse']),
      status: HelpRequestStatus.values.firstWhere((e) => e.toString() == 'HelpRequestStatus.${json['status']}'),
      acceptedBy: json['acceptedBy'],
      requestToken: json['requestToken'],
      deviceFingerprint: json['deviceFingerprint'],
      createdAt: DateTime.parse(json['createdAt']),
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      requesterName: json['requesterName'],
      location: LatLng(json['lat'], json['lng']),
      description: json['description'],
      distMeters: json['distMeters']?.toDouble(),
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
      'requesterName': requesterName,
      'lat': location.latitude,
      'lng': location.longitude,
      'description': description,
      'distMeters': distMeters,
    };
  }

  @override
  List<Object?> get props => [
        id, helpType, locationCoarse, status, acceptedBy, requestToken, 
        deviceFingerprint, createdAt, syncedAt, requesterName, location, 
        description, distMeters
      ];
}
