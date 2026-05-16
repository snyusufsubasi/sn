import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';

class SupportTicket {
  final String id;
  final String subject;
  final String? description;
  final String status;
  final String createdAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    this.description,
    this.status = 'open',
    required this.createdAt,
  });

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'open',
      createdAt: map['created_at'] as String,
    );
  }
}

class SupportRepository {
  final _client = SupabaseClientManager.instance.client;
  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<void> createTicket({
    required String subject,
    required String category,
    String? description,
  }) async {
    if (DevAuthService.isActive) return;

    await _client.from('support_tickets').insert({
      'user_id': _userId,
      'subject': subject,
      'category': category,
      'description': description,
    });
  }

  Future<List<SupportTicket>> getMyTickets() async {
    if (DevAuthService.isActive) return [];

    final response = await _client
        .from('support_tickets')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(SupportTicket.fromMap).toList();
  }
}
