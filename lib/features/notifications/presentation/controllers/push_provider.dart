import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_provider.dart';
import '../../data/services/push_notification_service.dart';

part 'push_provider.g.dart';

@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return PushNotificationService(client);
}
