import 'package:equatable/equatable.dart';

enum JobStatus {
  open,
  offerAccepted,
  pickupApproval,
  loaded,
  onRoad,
  deliveryApproval,
  awaitingPayment,
  completed,
  cancelled;

  static JobStatus fromString(String value) {
    switch (value) {
      case 'open':
        return JobStatus.open;
      case 'offer_accepted':
        return JobStatus.offerAccepted;
      case 'pickup_approval':
        return JobStatus.pickupApproval;
      case 'loaded':
        return JobStatus.loaded;
      case 'on_road':
        return JobStatus.onRoad;
      case 'delivery_approval':
        return JobStatus.deliveryApproval;
      case 'awaiting_payment':
        return JobStatus.awaitingPayment;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        throw ArgumentError('Unknown job_status: $value');
    }
  }

  String get dbValue {
    switch (this) {
      case JobStatus.open:
        return 'open';
      case JobStatus.offerAccepted:
        return 'offer_accepted';
      case JobStatus.pickupApproval:
        return 'pickup_approval';
      case JobStatus.loaded:
        return 'loaded';
      case JobStatus.onRoad:
        return 'on_road';
      case JobStatus.deliveryApproval:
        return 'delivery_approval';
      case JobStatus.awaitingPayment:
        return 'awaiting_payment';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isOpen => this == JobStatus.open;
  bool get isCompleted => this == JobStatus.completed;
  bool get isCancelled => this == JobStatus.cancelled;
  bool get isInProgress => !isOpen && !isCompleted && !isCancelled;
  bool get isActive => !isCancelled && !isCompleted;

  /// Detay bilgiler (açık adres, telefon) açık mı?
  bool get detailsRevealed => this != JobStatus.open && !isCancelled;
}

class JobPost extends Equatable {
  const JobPost({
    required this.id,
    required this.shipperId,
    required this.title,
    required this.cargoType, required this.weightTons, required this.originCity, required this.originDistrict, required this.destinationCity, required this.destinationDistrict, required this.pickupDate, required this.createdAt, this.description,
    this.volumeM3,
    this.originAddress,
    this.destinationAddress,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.deliveryDate,
    this.preferredTrailerType,
    this.budgetMin,
    this.budgetMax,
    this.status = JobStatus.open,
    this.acceptedOfferId,
    this.pickupConfirmedByCarrier = false,
    this.pickupConfirmedByShipper = false,
    this.deliveryConfirmedByCarrier = false,
    this.deliveryConfirmedByShipper = false,
    this.cancelledAt,
    this.cancelledReason,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] as String,
      shipperId: json['shipper_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      cargoType: json['cargo_type'] as String,
      weightTons: (json['weight_tons'] as num).toDouble(),
      volumeM3: (json['volume_m3'] as num?)?.toDouble(),
      originCity: json['origin_city'] as String,
      originDistrict: json['origin_district'] as String,
      destinationCity: json['destination_city'] as String,
      destinationDistrict: json['destination_district'] as String,
      originAddress: json['origin_address'] as String?,
      destinationAddress: json['destination_address'] as String?,
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      pickupDate: DateTime.parse(json['pickup_date'] as String),
      deliveryDate: json['delivery_date'] == null
          ? null
          : DateTime.parse(json['delivery_date'] as String),
      preferredTrailerType: json['preferred_trailer_type'] as String?,
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      status: JobStatus.fromString(json['status'] as String),
      acceptedOfferId: json['accepted_offer_id'] as String?,
      pickupConfirmedByCarrier:
          (json['pickup_confirmed_by_carrier'] as bool?) ?? false,
      pickupConfirmedByShipper:
          (json['pickup_confirmed_by_shipper'] as bool?) ?? false,
      deliveryConfirmedByCarrier:
          (json['delivery_confirmed_by_carrier'] as bool?) ?? false,
      deliveryConfirmedByShipper:
          (json['delivery_confirmed_by_shipper'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancelledReason: json['cancelled_reason'] as String?,
    );
  }

  final String id;
  final String shipperId;
  final String title;
  final String? description;
  final String cargoType;
  final double weightTons;
  final double? volumeM3;

  final String originCity;
  final String originDistrict;
  final String destinationCity;
  final String destinationDistrict;

  /// Sadece teklif kabul edildikten sonra dolu (RLS değil, UI maskelemesi).
  final String? originAddress;
  final String? destinationAddress;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;

  final DateTime pickupDate;
  final DateTime? deliveryDate;
  final String? preferredTrailerType;
  final double? budgetMin;
  final double? budgetMax;

  final JobStatus status;
  final String? acceptedOfferId;

  final bool pickupConfirmedByCarrier;
  final bool pickupConfirmedByShipper;
  final bool deliveryConfirmedByCarrier;
  final bool deliveryConfirmedByShipper;

  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;

  String get route => '$originCity → $destinationCity';

  bool get bothPickupConfirmed =>
      pickupConfirmedByCarrier && pickupConfirmedByShipper;
  bool get bothDeliveryConfirmed =>
      deliveryConfirmedByCarrier && deliveryConfirmedByShipper;

  /// Yeni ilan oluştururken kullanılan insert payload'u.
  Map<String, dynamic> toInsertJson() => {
        'shipper_id': shipperId,
        'title': title,
        'description': description,
        'cargo_type': cargoType,
        'weight_tons': weightTons,
        'volume_m3': volumeM3,
        'origin_city': originCity,
        'origin_district': originDistrict,
        'destination_city': destinationCity,
        'destination_district': destinationDistrict,
        'origin_address': originAddress,
        'destination_address': destinationAddress,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'destination_lat': destinationLat,
        'destination_lng': destinationLng,
        'pickup_date': pickupDate.toIso8601String().substring(0, 10),
        'delivery_date': deliveryDate?.toIso8601String().substring(0, 10),
        'preferred_trailer_type': preferredTrailerType,
        'budget_min': budgetMin,
        'budget_max': budgetMax,
      };

  @override
  List<Object?> get props => [
        id,
        shipperId,
        title,
        description,
        cargoType,
        weightTons,
        volumeM3,
        originCity,
        originDistrict,
        destinationCity,
        destinationDistrict,
        pickupDate,
        deliveryDate,
        budgetMin,
        budgetMax,
        status,
        acceptedOfferId,
        pickupConfirmedByCarrier,
        pickupConfirmedByShipper,
        deliveryConfirmedByCarrier,
        deliveryConfirmedByShipper,
        createdAt,
      ];
}

/// Ilan oluşturma akışında kullanılan input payload (henüz id yok).
class JobPostInput {
  JobPostInput({
    required this.title,
    required this.cargoType, required this.weightTons, required this.originCity, required this.originDistrict, required this.destinationCity, required this.destinationDistrict, required this.pickupDate, this.description,
    this.volumeM3,
    this.originAddress,
    this.destinationAddress,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.deliveryDate,
    this.preferredTrailerType,
    this.budgetMin,
    this.budgetMax,
  });

  final String title;
  final String? description;
  final String cargoType;
  final double weightTons;
  final double? volumeM3;
  final String originCity;
  final String originDistrict;
  final String destinationCity;
  final String destinationDistrict;
  final String? originAddress;
  final String? destinationAddress;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final DateTime pickupDate;
  final DateTime? deliveryDate;
  final String? preferredTrailerType;
  final double? budgetMin;
  final double? budgetMax;

  Map<String, dynamic> toJson(String shipperId) => {
        'shipper_id': shipperId,
        'title': title,
        if (description != null) 'description': description,
        'cargo_type': cargoType,
        'weight_tons': weightTons,
        if (volumeM3 != null) 'volume_m3': volumeM3,
        'origin_city': originCity,
        'origin_district': originDistrict,
        'destination_city': destinationCity,
        'destination_district': destinationDistrict,
        if (originAddress != null) 'origin_address': originAddress,
        if (destinationAddress != null)
          'destination_address': destinationAddress,
        if (originLat != null) 'origin_lat': originLat,
        if (originLng != null) 'origin_lng': originLng,
        if (destinationLat != null) 'destination_lat': destinationLat,
        if (destinationLng != null) 'destination_lng': destinationLng,
        'pickup_date': pickupDate.toIso8601String().substring(0, 10),
        if (deliveryDate != null)
          'delivery_date': deliveryDate!.toIso8601String().substring(0, 10),
        if (preferredTrailerType != null)
          'preferred_trailer_type': preferredTrailerType,
        if (budgetMin != null) 'budget_min': budgetMin,
        if (budgetMax != null) 'budget_max': budgetMax,
      };
}

enum JobSortBy { date, price, weight }
enum SortOrder { ascending, descending }

class JobFilter {
  const JobFilter({
    this.originCity,
    this.destinationCity,
    this.originRegion,
    this.destinationRegion,
    this.minWeight,
    this.maxWeight,
    this.cargoType,
    this.trailerType,
    this.sortBy = JobSortBy.date,
    this.sortOrder = SortOrder.descending,
  });

  final String? originCity;
  final String? destinationCity;
  final String? originRegion;
  final String? destinationRegion;
  final double? minWeight;
  final double? maxWeight;
  final String? cargoType;
  final String? trailerType;
  final JobSortBy sortBy;
  final SortOrder sortOrder;

  bool get isEmpty =>
      originCity == null &&
      destinationCity == null &&
      originRegion == null &&
      destinationRegion == null &&
      minWeight == null &&
      maxWeight == null &&
      cargoType == null &&
      trailerType == null;

  JobFilter copyWith({
    String? originCity,
    String? destinationCity,
    String? originRegion,
    String? destinationRegion,
    double? minWeight,
    double? maxWeight,
    String? cargoType,
    String? trailerType,
    JobSortBy? sortBy,
    SortOrder? sortOrder,
    bool clearOriginCity = false,
    bool clearDestinationCity = false,
    bool clearOriginRegion = false,
    bool clearDestinationRegion = false,
    bool clearCargoType = false,
    bool clearTrailerType = false,
  }) {
    return JobFilter(
      originCity:
          clearOriginCity ? null : (originCity ?? this.originCity),
      destinationCity: clearDestinationCity
          ? null
          : (destinationCity ?? this.destinationCity),
      originRegion: clearOriginRegion
          ? null
          : (originRegion ?? this.originRegion),
      destinationRegion: clearDestinationRegion
          ? null
          : (destinationRegion ?? this.destinationRegion),
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      cargoType: clearCargoType ? null : (cargoType ?? this.cargoType),
      trailerType:
          clearTrailerType ? null : (trailerType ?? this.trailerType),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
