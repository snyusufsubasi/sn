/// Demo mod sabitleri — telefon → kullanıcı eşlemesi ve seed id'ler.
class DemoConstants {
  DemoConstants._();

  static const shipperPhone = '+905551111111';
  static const carrierPhone = '+905552222222';
  static const demoOtp = '123456';

  static const shipperId = 'demo-shipper-001';
  static const carrierId = 'demo-carrier-001';

  static const jobOpenId = 'demo-job-open-001';
  static const jobPickupId = 'demo-job-pickup-001';
  static const jobOnRoadId = 'demo-job-onroad-001';
  static const jobCompletedId = 'demo-job-completed-001';

  static const offerPendingId = 'demo-offer-pending-001';
  static const offerAcceptedPickupId = 'demo-offer-accepted-pickup';
  static const offerAcceptedOnRoadId = 'demo-offer-accepted-onroad';
  static const offerAcceptedCompletedId = 'demo-offer-accepted-completed';

  static const threadPickupId = 'demo-thread-pickup';
  static const threadOnRoadId = 'demo-thread-onroad';

  /// Telefon E.164 → demo kullanıcı id (null = bilinmeyen).
  static String? userIdForPhone(String phoneE164) {
    if (phoneE164 == shipperPhone) return shipperId;
    if (phoneE164 == carrierPhone) return carrierId;
    return null;
  }

  static bool isDemoPhone(String phoneE164) => userIdForPhone(phoneE164) != null;
}
