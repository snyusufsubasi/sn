import '../../../../core/errors/result.dart';
import '../models/admin_overview.dart';

abstract interface class AdminRepository {
  Future<Result<AdminOverview>> fetchOverview();
}
