import 'package:equatable/equatable.dart';

class VolunteerProfile extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final bool isVerified;
  final DateTime createdAt;

  const VolunteerProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.isVerified,
    required this.createdAt,
  });

  factory VolunteerProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerProfile(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  VolunteerProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return VolunteerProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, phone, isVerified, createdAt];
}
