import 'package:equatable/equatable.dart';

enum UserRole {
  shipper,
  carrier;

  static UserRole fromString(String value) =>
      UserRole.values.firstWhere((e) => e.name == value);
}

enum UserType {
  individual,
  company;

  static UserType fromString(String value) =>
      UserType.values.firstWhere((e) => e.name == value);
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.role,
    required this.userType,
    required this.fullName,
    required this.city,
    required this.district,
    this.companyName,
    this.taxNumber,
    this.avatarUrl,
    this.ratingAvg = 0,
    this.completedJobsCount = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      role: UserRole.fromString(json['role'] as String),
      userType: UserType.fromString(
        (json['user_type'] as String?) ?? 'individual',
      ),
      fullName: json['full_name'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      companyName: json['company_name'] as String?,
      taxNumber: json['tax_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      completedJobsCount: (json['completed_jobs_count'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final UserRole role;
  final UserType userType;
  final String fullName;
  final String city;
  final String district;
  final String? companyName;
  final String? taxNumber;
  final String? avatarUrl;
  final double ratingAvg;
  final int completedJobsCount;
  final bool isActive;
  final DateTime? createdAt;

  bool get isShipper => role == UserRole.shipper;
  bool get isCarrier => role == UserRole.carrier;
  bool get isCompany => userType == UserType.company;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'user_type': userType.name,
        'full_name': fullName,
        'city': city,
        'district': district,
        if (companyName != null) 'company_name': companyName,
        if (taxNumber != null) 'tax_number': taxNumber,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'is_active': isActive,
      };

  UserProfile copyWith({
    String? fullName,
    String? city,
    String? district,
    String? companyName,
    String? taxNumber,
    String? avatarUrl,
    double? ratingAvg,
    int? completedJobsCount,
    bool? isActive,
  }) {
    return UserProfile(
      id: id,
      role: role,
      userType: userType,
      fullName: fullName ?? this.fullName,
      city: city ?? this.city,
      district: district ?? this.district,
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        userType,
        fullName,
        city,
        district,
        companyName,
        taxNumber,
        avatarUrl,
        ratingAvg,
        completedJobsCount,
        isActive,
      ];
}
