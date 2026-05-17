import 'package:equatable/equatable.dart';

class AdminOverview extends Equatable {
  const AdminOverview({
    required this.totalUsers,
    required this.openJobs,
    required this.openDisputes,
    required this.pendingPayments,
  });

  final int totalUsers;
  final int openJobs;
  final int openDisputes;
  final int pendingPayments;

  @override
  List<Object?> get props => [
        totalUsers,
        openJobs,
        openDisputes,
        pendingPayments,
      ];
}
