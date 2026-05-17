import '../../features/jobs/data/models/job_post.dart';
import '../../features/messages/data/models/message.dart';
import '../../features/messages/data/models/message_thread.dart';
import '../../features/notifications/data/models/app_notification.dart';
import '../../features/offers/data/models/offer.dart';
import '../../features/payments/data/models/payment_record.dart';
import '../../features/profile/data/models/carrier_profile.dart';
import '../../features/profile/data/models/user_profile.dart';
import '../../features/reviews/data/models/review.dart';
import '../../features/tracking/data/models/location_ping.dart';

/// In-memory demo uygulama durumu.
class DemoAppState {
  const DemoAppState({
    this.currentUserId,
    this.version = 0,
    this.profiles = const {},
    this.carrierProfiles = const {},
    this.jobs = const {},
    this.offers = const {},
    this.threads = const {},
    this.messagesByThread = const {},
    this.notificationsByUser = const {},
    this.reviews = const [],
    this.pingsByJob = const {},
    this.paymentsByJob = const {},
  });

  final String? currentUserId;
  final int version;
  final Map<String, UserProfile> profiles;
  final Map<String, CarrierProfile> carrierProfiles;
  final Map<String, JobPost> jobs;
  final Map<String, Offer> offers;
  final Map<String, MessageThread> threads;
  final Map<String, List<Message>> messagesByThread;
  final Map<String, List<AppNotification>> notificationsByUser;
  final List<Review> reviews;
  final Map<String, List<LocationPing>> pingsByJob;
  final Map<String, PaymentRecord> paymentsByJob;

  DemoAppState copyWith({
    String? currentUserId,
    bool clearCurrentUser = false,
    int? version,
    Map<String, UserProfile>? profiles,
    Map<String, CarrierProfile>? carrierProfiles,
    Map<String, JobPost>? jobs,
    Map<String, Offer>? offers,
    Map<String, MessageThread>? threads,
    Map<String, List<Message>>? messagesByThread,
    Map<String, List<AppNotification>>? notificationsByUser,
    List<Review>? reviews,
    Map<String, List<LocationPing>>? pingsByJob,
    Map<String, PaymentRecord>? paymentsByJob,
  }) {
    return DemoAppState(
      currentUserId:
          clearCurrentUser ? null : (currentUserId ?? this.currentUserId),
      version: version ?? this.version,
      profiles: profiles ?? this.profiles,
      carrierProfiles: carrierProfiles ?? this.carrierProfiles,
      jobs: jobs ?? this.jobs,
      offers: offers ?? this.offers,
      threads: threads ?? this.threads,
      messagesByThread: messagesByThread ?? this.messagesByThread,
      notificationsByUser:
          notificationsByUser ?? this.notificationsByUser,
      reviews: reviews ?? this.reviews,
      pingsByJob: pingsByJob ?? this.pingsByJob,
      paymentsByJob: paymentsByJob ?? this.paymentsByJob,
    );
  }

  DemoAppState bump() => copyWith(version: version + 1);
}
