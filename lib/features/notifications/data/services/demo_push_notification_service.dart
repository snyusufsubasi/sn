/// Demo modda push yok — no-op servis.
class DemoPushNotificationService {
  void Function(Map<String, dynamic> data)? onNotificationTap;

  Future<void> initialize() async {}

  Future<void> deactivateCurrentToken() async {}
}
