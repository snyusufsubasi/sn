import '../../../../core/errors/result.dart';
import '../models/payment_record.dart';

abstract interface class PaymentsRepository {
  Future<Result<PaymentRecord?>> fetchPaymentByJobId(String jobId);
  Future<Result<void>> releasePayment(String jobId);
  Future<Result<void>> confirmCarrierPayment(String jobId);
  Future<Result<void>> reportShipperTransfer(String jobId);
}
