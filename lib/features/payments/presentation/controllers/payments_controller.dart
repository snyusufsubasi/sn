import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/supabase_provider.dart';
import '../../../jobs/presentation/controllers/jobs_controller.dart';
import '../../data/models/payment_record.dart';
import '../../data/repositories/demo_payments_repository.dart';
import '../../data/repositories/payments_repository.dart';
import '../../data/repositories/supabase_payments_repository.dart';

part 'payments_controller.g.dart';

@Riverpod(keepAlive: true)
PaymentsRepository paymentsRepository(Ref ref) {
  if (AppConfig.demoMode) return DemoPaymentsRepository(ref);
  final client = ref.watch(supabaseClientProvider);
  return SupabasePaymentsRepository(client);
}

@riverpod
Future<PaymentRecord?> paymentByJob(Ref ref, String jobId) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  final result = await repo.fetchPaymentByJobId(jobId);
  return result.when(
    success: (payment) => payment,
    failure: (f) => throw f,
  );
}

@riverpod
class ConfirmCarrierPaymentController extends _$ConfirmCarrierPaymentController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> confirm(String jobId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(paymentsRepositoryProvider);
    final result = await repo.confirmCarrierPayment(jobId);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(paymentByJobProvider(jobId));
        ref.invalidate(jobDetailProvider(jobId));
        ref.invalidate(myJobsProvider);
        ref.invalidate(myActiveCarrierJobsProvider);
        ref.invalidate(myInProgressShipperJobsProvider);
        return true;
      },
      failure: (AppFailure f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}

@riverpod
class ReportShipperTransferController extends _$ReportShipperTransferController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> report(String jobId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(paymentsRepositoryProvider);
    final result = await repo.reportShipperTransfer(jobId);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(paymentByJobProvider(jobId));
        return true;
      },
      failure: (AppFailure f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}

@riverpod
class ReleasePaymentController extends _$ReleasePaymentController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> release(String jobId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(paymentsRepositoryProvider);
    final result = await repo.releasePayment(jobId);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(paymentByJobProvider(jobId));
        return true;
      },
      failure: (AppFailure f) {
        state = AsyncValue.error(f, StackTrace.current);
        return false;
      },
    );
  }
}
