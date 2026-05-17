import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/payment_record.dart';
import 'payments_repository.dart';

class SupabasePaymentsRepository implements PaymentsRepository {
  SupabasePaymentsRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<PaymentRecord?>> fetchPaymentByJobId(String jobId) async {
    try {
      final rows = await _client
          .from('payments')
          .select()
          .eq('job_post_id', jobId)
          .limit(1);

      if (rows.isEmpty) {
        return const Success(null);
      }

      final map = rows.first;
      return Success(PaymentRecord.fromJson(map));
    } on Object catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> releasePayment(String jobId) async {
    try {
      await _client.rpc<void>('release_payment', params: {'p_job_id': jobId});
      return const Success(null);
    } on PostgrestException catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    } on Object catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> reportShipperTransfer(String jobId) async {
    try {
      await _client.rpc<void>(
        'report_shipper_transfer',
        params: {'p_job_id': jobId},
      );
      return const Success(null);
    } on PostgrestException catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    } on Object catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<void>> confirmCarrierPayment(String jobId) async {
    try {
      await _client.rpc<void>(
        'confirm_carrier_payment',
        params: {'p_job_id': jobId},
      );
      return const Success(null);
    } on PostgrestException catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    } on Object catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }
}
