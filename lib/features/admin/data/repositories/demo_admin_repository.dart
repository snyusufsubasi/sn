import '../../../../core/errors/result.dart';
import '../models/admin_overview.dart';
import 'admin_repository.dart';

class DemoAdminRepository implements AdminRepository {
  const DemoAdminRepository();

  @override
  Future<Result<AdminOverview>> fetchOverview() async {
    return const Success(
      AdminOverview(
        totalUsers: 2,
        openJobs: 1,
        openDisputes: 0,
        pendingPayments: 1,
      ),
    );
  }
}
