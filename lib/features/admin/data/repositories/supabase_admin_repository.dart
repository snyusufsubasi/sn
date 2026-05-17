import '../../../../core/errors/result.dart';
import '../../../../core/network/exception_handler.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/admin_overview.dart';
import 'admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  SupabaseAdminRepository(this._client);

  final SupabaseClientWrapper _client;

  @override
  Future<Result<AdminOverview>> fetchOverview() async {
    try {
      final users = await _client
          .from('profiles')
          .select('id');
      final openJobs = await _client
          .from('job_posts')
          .select('id')
          .eq('status', 'open');
      final disputes = await _client
          .from('disputes')
          .select('id')
          .eq('status', 'open');
      final pendingPayments = await _client
          .from('payments')
          .select('id')
          .inFilter('status', ['pending', 'paid', 'held']);

      return Success(
        AdminOverview(
          totalUsers: users.length,
          openJobs: openJobs.length,
          openDisputes: disputes.length,
          pendingPayments: pendingPayments.length,
        ),
      );
    } on Object catch (e, st) {
      return ResultFailure(mapExceptionToFailure(e, st));
    }
  }
}
