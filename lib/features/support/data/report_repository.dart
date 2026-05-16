import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';

class Report {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? jobPostId;
  final String reason;
  final String? description;
  final String status;
  final String createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.jobPostId,
    required this.reason,
    this.description,
    this.status = 'open',
    required this.createdAt,
  });

  factory Report.fromMap(Map<String, dynamic> map) => Report(
    id: map['id'] as String,
    reporterId: map['reporter_id'] as String,
    reportedUserId: map['reported_user_id'] as String?,
    jobPostId: map['job_post_id'] as String?,
    reason: map['reason'] as String,
    description: map['description'] as String?,
    status: map['status'] as String? ?? 'open',
    createdAt: map['created_at'] as String,
  );
}

class ReportRepository {
  final _client = SupabaseClientManager.instance.client;
  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<void> createReport({
    required String reason,
    String? description,
    String? reportedUserId,
    String? jobPostId,
  }) async {
    if (DevAuthService.isActive) return;

    await _client.from('reports').insert({
      'reporter_id': _userId,
      'reason': reason,
      'description': description,
      'reported_user_id': reportedUserId,
      'job_post_id': jobPostId,
    });
  }
}
