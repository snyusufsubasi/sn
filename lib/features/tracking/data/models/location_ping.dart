import 'package:equatable/equatable.dart';

class LocationPing extends Equatable {
  const LocationPing({
    required this.id,
    required this.jobPostId,
    required this.carrierId,
    required this.lat,
    required this.lng,
    required this.recordedAt, this.accuracyM,
    this.speedKmh,
    this.headingDeg,
  });

  factory LocationPing.fromJson(Map<String, dynamic> json) {
    return LocationPing(
      id: json['id'] as int,
      jobPostId: json['job_post_id'] as String,
      carrierId: json['carrier_id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num?)?.toDouble(),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
      headingDeg: (json['heading_deg'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  final int id;
  final String jobPostId;
  final String carrierId;
  final double lat;
  final double lng;
  final double? accuracyM;
  final double? speedKmh;
  final double? headingDeg;
  final DateTime recordedAt;

  @override
  List<Object?> get props =>
      [id, jobPostId, carrierId, lat, lng, recordedAt];
}
