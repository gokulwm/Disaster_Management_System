import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum MarkerType { food, shelter, danger, medical, grocery }

class MarkerModel extends Equatable {
  final String id;
  final MarkerType type;
  final LatLng location;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;

  const MarkerModel({
    required this.id,
    required this.type,
    required this.location,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      id: json['id'],
      type: MarkerType.values.firstWhere((e) => e.toString() == 'MarkerType.${json['type']}'),
      location: LatLng(json['lat'], json['lng']),
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'lat': location.latitude,
      'lng': location.longitude,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  MarkerModel copyWith({
    String? id,
    MarkerType? type,
    LatLng? location,
    String? title,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return MarkerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, type, location, title, description, createdBy, createdAt, isActive];
}
