import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/demo/demo_provider.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/payment_record.dart';
import 'payments_repository.dart';

class DemoPaymentsRepository implements PaymentsRepository {
  DemoPaymentsRepository(this._ref);

  final Ref _ref;

  DemoStore get _store => _ref.read(demoStoreProvider);

  @override
  Future<Result<PaymentRecord?>> fetchPaymentByJobId(String jobId) async {
    return Success(_store.paymentForJob(jobId));
  }

  @override
  Future<Result<void>> releasePayment(String jobId) async {
    _store.releasePaymentEscrow(jobId);
    return const Success(null);
  }

  @override
  Future<Result<void>> reportShipperTransfer(String jobId) async {
    final uid = _store.state.currentUserId;
    if (uid == null) {
      return const ResultFailure(
        UnknownFailure(message: 'Oturum gerekli'),
      );
    }
    _store.reportShipperTransfer(jobId, uid);
    return const Success(null);
  }

  @override
  Future<Result<void>> confirmCarrierPayment(String jobId) async {
    final uid = _store.state.currentUserId;
    if (uid == null) {
      return const ResultFailure(
        UnknownFailure(message: 'Oturum gerekli'),
      );
    }
    _store.confirmCarrierPayment(jobId, uid);
    return const Success(null);
  }
}
