/// Tüm route path'leri tek noktadan. Magic string yasak.
class RoutePaths {
  RoutePaths._();

  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const roleSelection = '/role-selection';
  static const profileSetup = '/profile-setup';
  static const carrierProfileSetup = '/carrier-profile-setup';

  // Shell rotaları
  static const home = '/home';
  static const jobs = '/jobs';
  static const notifications = '/notifications';
  static const messages = '/messages';
  static const profile = '/profile';

  // Detay rotaları (Faz 4+ implement edilecek)
  static const jobDetail = '/jobs/:id';
  static const jobFlow = '/jobs/:id/flow';
  static const createJob = '/jobs/new';
  static const myOffers = '/offers/my';
  static const jobTracking = '/jobs/:id/track';
  static const jobPayment = '/jobs/:id/payment';
  static const offerDetail = '/offers/:id';
  static const messageThread = '/messages/:threadId';
  static const editProfile = '/profile/edit';
  static const legalTerms = '/legal/terms';
  static const legalPrivacy = '/legal/privacy';
  static const legalHelp = '/legal/help';
}
