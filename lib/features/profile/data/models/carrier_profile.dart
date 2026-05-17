import 'package:equatable/equatable.dart';

class CarrierProfile extends Equatable {
  const CarrierProfile({
    required this.userId,
    required this.vehicleType,
    required this.capacityTons,
    required this.trailerType,
    required this.plate,
    this.iban,
    this.serviceRegions = const [],
    this.documentsUploaded = false,
    this.isVerified = false,
  });

  factory CarrierProfile.fromJson(Map<String, dynamic> json) {
    return CarrierProfile(
      userId: json['user_id'] as String,
      vehicleType: json['vehicle_type'] as String,
      capacityTons: (json['capacity_tons'] as num).toDouble(),
      trailerType: json['trailer_type'] as String,
      plate: json['plate'] as String,
      iban: json['iban'] as String?,
      serviceRegions: (json['service_regions'] as List?)?.cast<String>() ?? [],
      documentsUploaded: (json['documents_uploaded'] as bool?) ?? false,
      isVerified: (json['is_verified'] as bool?) ?? false,
    );
  }

  final String userId;
  final String vehicleType; // 'Kamyon' | 'Tır'
  final double capacityTons;
  final String trailerType; // 'Tenteli' | 'Açık Kasa' | 'Kapalı Kasa' | ...
  final String plate;
  final String? iban;
  final List<String> serviceRegions;
  final bool documentsUploaded;
  final bool isVerified;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'vehicle_type': vehicleType,
        'capacity_tons': capacityTons,
        'trailer_type': trailerType,
        'plate': plate,
        if (iban != null) 'iban': iban,
        'service_regions': serviceRegions,
      };

  @override
  List<Object?> get props => [
        userId,
        vehicleType,
        capacityTons,
        trailerType,
        plate,
        iban,
        serviceRegions,
        documentsUploaded,
        isVerified,
      ];
}
