import 'package:equatable/equatable.dart';

enum PaymentStatus {
  pending,
  awaitingTransfer,
  held,
  carrierConfirmed,
  released,
  refunded,
  disputed,
}

extension PaymentStatusX on PaymentStatus {
  static PaymentStatus fromDb(String raw) {
    return switch (raw) {
      'pending' => PaymentStatus.pending,
      'awaiting_transfer' => PaymentStatus.awaitingTransfer,
      'held' => PaymentStatus.held,
      'carrier_confirmed' => PaymentStatus.carrierConfirmed,
      'released' => PaymentStatus.released,
      'refunded' => PaymentStatus.refunded,
      'disputed' => PaymentStatus.disputed,
      _ => PaymentStatus.pending,
    };
  }

  String get dbValue {
    return switch (this) {
      PaymentStatus.pending => 'pending',
      PaymentStatus.awaitingTransfer => 'awaiting_transfer',
      PaymentStatus.held => 'held',
      PaymentStatus.carrierConfirmed => 'carrier_confirmed',
      PaymentStatus.released => 'released',
      PaymentStatus.refunded => 'refunded',
      PaymentStatus.disputed => 'disputed',
    };
  }
}

class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.jobPostId,
    required this.offerId,
    required this.shipperId,
    required this.carrierId,
    required this.amount,
    required this.commissionAmount,
    required this.carrierPayout,
    required this.status,
    required this.createdAt,
    this.releasedAt,
    this.shipperReportedTransferAt,
    this.provider,
    this.providerPaymentId,
  });

  final String id;
  final String jobPostId;
  final String offerId;
  final String shipperId;
  final String carrierId;
  final double amount;
  final double commissionAmount;
  final double carrierPayout;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? releasedAt;
  final DateTime? shipperReportedTransferAt;
  final String? provider;
  final String? providerPaymentId;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    double parseNum(Object? value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return PaymentRecord(
      id: json['id'] as String,
      jobPostId: json['job_post_id'] as String,
      offerId: json['offer_id'] as String,
      shipperId: json['shipper_id'] as String,
      carrierId: json['carrier_id'] as String,
      amount: parseNum(json['amount']),
      commissionAmount: parseNum(json['commission_amount']),
      carrierPayout: parseNum(json['carrier_payout']),
      status: PaymentStatusX.fromDb(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : null,
      shipperReportedTransferAt: json['shipper_reported_transfer_at'] != null
          ? DateTime.parse(json['shipper_reported_transfer_at'] as String)
          : null,
      provider: json['provider'] as String?,
      providerPaymentId: json['provider_payment_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobPostId,
        offerId,
        shipperId,
        carrierId,
        amount,
        commissionAmount,
        carrierPayout,
        status,
        createdAt,
        releasedAt,
        shipperReportedTransferAt,
        provider,
        providerPaymentId,
      ];
}
