import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

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
import 'demo_app_state.dart';
import 'demo_constants.dart';

/// Demo mod in-memory veri ve RPC taklidi.
class DemoStore {
  DemoStore({this.onStateChanged}) : _state = _buildSeed();

  final void Function()? onStateChanged;

  DemoAppState _state;
  final _uuid = const Uuid();
  final _jobWatchControllers = <String, StreamController<JobPost>>{};

  DemoAppState get state => _state;

  void _emit() {
    _state = _state.bump();
    onStateChanged?.call();
    for (final entry in _jobWatchControllers.entries) {
      final job = _state.jobs[entry.key];
      if (job != null && !entry.value.isClosed) {
        entry.value.add(job);
      }
    }
  }

  void setCurrentUser(String? userId) {
    _state = _state.copyWith(currentUserId: userId);
    _emit();
  }

  Stream<JobPost> watchJob(String id) {
    final existing = _jobWatchControllers[id];
    if (existing != null) return existing.stream;

    final controller = StreamController<JobPost>.broadcast();
    _jobWatchControllers[id] = controller;
    final job = _state.jobs[id];
    if (job != null) {
      Future.microtask(() => controller.add(job));
    }
    return controller.stream;
  }

  UserProfile? profile(String id) => _state.profiles[id];

  JobPost? job(String id) => _state.jobs[id];

  Offer? offer(String id) => _state.offers[id];

  List<AppNotification> notificationsFor(String userId) =>
      _state.notificationsByUser[userId] ?? [];

  void _notifyUser(
    String userId,
    NotificationType type,
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) {
    final list = List<AppNotification>.from(
      _state.notificationsByUser[userId] ?? [],
    );
    list.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
    _state = _state.copyWith(
      notificationsByUser: {..._state.notificationsByUser, userId: list},
    );
  }

  JobPost _setJob(JobPost job) {
    final jobs = Map<String, JobPost>.from(_state.jobs)..[job.id] = job;
    _state = _state.copyWith(jobs: jobs);
    return job;
  }

  static DemoAppState _buildSeed() {
    final now = DateTime.now();
    final shipper = UserProfile(
      id: DemoConstants.shipperId,
      role: UserRole.shipper,
      userType: UserType.company,
      fullName: 'Demo Yükveren A.Ş.',
      city: 'İstanbul',
      district: 'Kadıköy',
      companyName: 'Demo Yükveren',
      taxNumber: '1234567890',
      ratingAvg: 4.6,
      completedJobsCount: 12,
      createdAt: now.subtract(const Duration(days: 90)),
    );
    final carrier = UserProfile(
      id: DemoConstants.carrierId,
      role: UserRole.carrier,
      userType: UserType.individual,
      fullName: 'Demo Nakliyeci',
      city: 'Ankara',
      district: 'Çankaya',
      ratingAvg: 4.8,
      completedJobsCount: 28,
      createdAt: now.subtract(const Duration(days: 120)),
    );

    final carrierProfile = CarrierProfile(
      userId: DemoConstants.carrierId,
      vehicleType: 'Tır',
      capacityTons: 24,
      trailerType: 'Tenteli',
      plate: '34 ABC 123',
      iban: 'TR330006100519786457841326',
      serviceRegions: ['Marmara', 'İç Anadolu'],
      isVerified: true,
    );

    JobPost mkJob({
      required String id,
      required JobStatus status,
      required String title,
      String? acceptedOfferId,
      String originCity = 'İstanbul',
      String originDistrict = 'Tuzla',
      String destinationCity = 'Ankara',
      String destinationDistrict = 'Sincan',
      String cargoType = 'Paletli',
      double weightTons = 12,
      double? budgetMin = 18000,
      double? budgetMax = 22000,
      bool pickupCarrier = false,
      bool pickupShipper = false,
      bool deliveryCarrier = false,
      bool deliveryShipper = false,
      double? oLat,
      double? oLng,
      double? dLat,
      double? dLng,
    }) {
      return JobPost(
        id: id,
        shipperId: DemoConstants.shipperId,
        title: title,
        cargoType: cargoType,
        weightTons: weightTons,
        originCity: originCity,
        originDistrict: originDistrict,
        destinationCity: destinationCity,
        destinationDistrict: destinationDistrict,
        originAddress: '$originDistrict Lojistik Bölgesi',
        destinationAddress: '$destinationDistrict Organize Sanayi',
        originLat: oLat ?? 40.816,
        originLng: oLng ?? 29.300,
        destinationLat: dLat ?? 39.970,
        destinationLng: dLng ?? 32.580,
        pickupDate: now.add(const Duration(days: 2)),
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        status: status,
        acceptedOfferId: acceptedOfferId,
        pickupConfirmedByCarrier: pickupCarrier,
        pickupConfirmedByShipper: pickupShipper,
        deliveryConfirmedByCarrier: deliveryCarrier,
        deliveryConfirmedByShipper: deliveryShipper,
        createdAt: now.subtract(const Duration(days: 1)),
      );
    }

    final jobs = {
      DemoConstants.jobOpenId: mkJob(
        id: DemoConstants.jobOpenId,
        status: JobStatus.open,
        title: 'İstanbul → Ankara paletli yük',
      ),
      'demo-job-open-izmir-gaziantep': mkJob(
        id: 'demo-job-open-izmir-gaziantep',
        status: JobStatus.open,
        title: 'İzmir → Gaziantep gıda sevkiyatı',
        originCity: 'İzmir',
        originDistrict: 'Bornova',
        destinationCity: 'Gaziantep',
        destinationDistrict: 'Şehitkamil',
        cargoType: 'Gıda',
        weightTons: 16,
        budgetMin: 21000,
        budgetMax: 26000,
      ),
      'demo-job-open-trabzon-bursa': mkJob(
        id: 'demo-job-open-trabzon-bursa',
        status: JobStatus.open,
        title: 'Trabzon → Bursa tekstil',
        originCity: 'Trabzon',
        originDistrict: 'Ortahisar',
        destinationCity: 'Bursa',
        destinationDistrict: 'Nilüfer',
        cargoType: 'Tekstil',
        weightTons: 11,
        budgetMin: 17500,
        budgetMax: 22000,
      ),
      'demo-job-open-kars-antalya': mkJob(
        id: 'demo-job-open-kars-antalya',
        status: JobStatus.open,
        title: 'Kars → Antalya soğuk zincir',
        originCity: 'Kars',
        originDistrict: 'Merkez',
        destinationCity: 'Antalya',
        destinationDistrict: 'Kepez',
        cargoType: 'Soğuk Zincir',
        weightTons: 9,
        budgetMin: 23000,
        budgetMax: 28500,
      ),
      'demo-job-open-van-konya': mkJob(
        id: 'demo-job-open-van-konya',
        status: JobStatus.open,
        title: 'Van → Konya inşaat malzemesi',
        originCity: 'Van',
        originDistrict: 'Edremit',
        destinationCity: 'Konya',
        destinationDistrict: 'Selçuklu',
        cargoType: 'İnşaat Malzemesi',
        weightTons: 20,
        budgetMin: 24500,
        budgetMax: 30000,
      ),
      'demo-job-open-samsun-adana': mkJob(
        id: 'demo-job-open-samsun-adana',
        status: JobStatus.open,
        title: 'Samsun → Adana beyaz eşya',
        originCity: 'Samsun',
        originDistrict: 'Atakum',
        destinationCity: 'Adana',
        destinationDistrict: 'Yüreğir',
        cargoType: 'Beyaz Eşya',
        weightTons: 13,
        budgetMin: 19500,
        budgetMax: 24500,
      ),
      'demo-job-open-diyarbakir-izmir': mkJob(
        id: 'demo-job-open-diyarbakir-izmir',
        status: JobStatus.open,
        title: 'Diyarbakır → İzmir genel yük',
        originCity: 'Diyarbakır',
        originDistrict: 'Kayapınar',
        destinationCity: 'İzmir',
        destinationDistrict: 'Aliağa',
        cargoType: 'Genel Yük',
        weightTons: 14,
        budgetMin: 20500,
        budgetMax: 25500,
      ),
      'demo-job-10-1': mkJob(
        id: 'demo-job-10-1',
        status: JobStatus.open,
        title: 'İstanbul → Ankara tekstil sevkiyatı',
        originCity: 'İstanbul',
        originDistrict: 'Pendik',
        destinationCity: 'Ankara',
        destinationDistrict: 'Çankaya',
        cargoType: 'Tekstil',
        weightTons: 22,
        budgetMin: 25000,
        budgetMax: 30000,
      ),
      'demo-job-10-2': mkJob(
        id: 'demo-job-10-2',
        status: JobStatus.open,
        title: 'İzmir → Konya gıda sevkiyatı',
        originCity: 'İzmir',
        originDistrict: 'Konak',
        destinationCity: 'Konya',
        destinationDistrict: 'Meram',
        cargoType: 'Gıda',
        weightTons: 8,
        budgetMin: 15000,
        budgetMax: 19000,
      ),
      'demo-job-10-3': mkJob(
        id: 'demo-job-10-3',
        status: JobStatus.open,
        title: 'Bursa → Antalya otomotiv parçası',
        originCity: 'Bursa',
        originDistrict: 'Osmangazi',
        destinationCity: 'Antalya',
        destinationDistrict: 'Muratpaşa',
        cargoType: 'Otomotiv',
        weightTons: 12,
        budgetMin: 19000,
        budgetMax: 24000,
      ),
      'demo-job-10-4': mkJob(
        id: 'demo-job-10-4',
        status: JobStatus.open,
        title: 'Adana → Mersin tarım ürünü',
        originCity: 'Adana',
        originDistrict: 'Seyhan',
        destinationCity: 'Mersin',
        destinationDistrict: 'Akdeniz',
        cargoType: 'Tarım Ürünü',
        weightTons: 25,
        budgetMin: 16000,
        budgetMax: 20000,
      ),
      'demo-job-10-5': mkJob(
        id: 'demo-job-10-5',
        status: JobStatus.open,
        title: 'Trabzon → Samsun soğuk zincir',
        originCity: 'Trabzon',
        originDistrict: 'Ortahisar',
        destinationCity: 'Samsun',
        destinationDistrict: 'İlkadım',
        cargoType: 'Soğuk Zincir',
        weightTons: 6,
        budgetMin: 17000,
        budgetMax: 21000,
      ),
      'demo-job-10-6': mkJob(
        id: 'demo-job-10-6',
        status: JobStatus.open,
        title: 'Gaziantep → Diyarbakır tekstil',
        originCity: 'Gaziantep',
        originDistrict: 'Şahinbey',
        destinationCity: 'Diyarbakır',
        destinationDistrict: 'Kayapınar',
        cargoType: 'Tekstil',
        weightTons: 20,
        budgetMin: 16000,
        budgetMax: 20000,
      ),
      'demo-job-10-7': mkJob(
        id: 'demo-job-10-7',
        status: JobStatus.open,
        title: 'Ankara → İstanbul genel yük',
        originCity: 'Ankara',
        originDistrict: 'Yenimahalle',
        destinationCity: 'İstanbul',
        destinationDistrict: 'Esenler',
        cargoType: 'Genel Yük',
        weightTons: 18,
        budgetMin: 20000,
        budgetMax: 25000,
      ),
      'demo-job-10-8': mkJob(
        id: 'demo-job-10-8',
        status: JobStatus.open,
        title: 'Kayseri → Konya inşaat malzemesi',
        originCity: 'Kayseri',
        originDistrict: 'Melikgazi',
        destinationCity: 'Konya',
        destinationDistrict: 'Selçuklu',
        cargoType: 'İnşaat Malzemesi',
        weightTons: 28,
        budgetMin: 18000,
        budgetMax: 23000,
      ),
      'demo-job-10-9': mkJob(
        id: 'demo-job-10-9',
        status: JobStatus.open,
        title: 'Antalya → İstanbul gıda sevkiyatı',
        originCity: 'Antalya',
        originDistrict: 'Kepez',
        destinationCity: 'İstanbul',
        destinationDistrict: 'Kartal',
        cargoType: 'Gıda',
        weightTons: 10,
        budgetMin: 22000,
        budgetMax: 27000,
      ),
      'demo-job-10-10': mkJob(
        id: 'demo-job-10-10',
        status: JobStatus.open,
        title: 'Samsun → Ankara genel yük',
        originCity: 'Samsun',
        originDistrict: 'Atakum',
        destinationCity: 'Ankara',
        destinationDistrict: 'Altındağ',
        cargoType: 'Genel Yük',
        weightTons: 15,
        budgetMin: 17000,
        budgetMax: 21000,
      ),
      DemoConstants.jobPickupId: mkJob(
        id: DemoConstants.jobPickupId,
        status: JobStatus.pickupApproval,
        title: 'Kocaeli → Eskişehir makine parçası',
        acceptedOfferId: DemoConstants.offerAcceptedPickupId,
        originCity: 'Kocaeli',
        originDistrict: 'Gebze',
        destinationCity: 'Eskişehir',
        destinationDistrict: 'Tepebaşı',
        cargoType: 'Otomotiv',
        weightTons: 15,
        pickupCarrier: true,
        oLat: 40.765,
        oLng: 29.940,
        dLat: 39.776,
        dLng: 30.520,
      ),
      DemoConstants.jobOnRoadId: mkJob(
        id: DemoConstants.jobOnRoadId,
        status: JobStatus.onRoad,
        title: 'Bursa → İzmir tekstil',
        acceptedOfferId: DemoConstants.offerAcceptedOnRoadId,
        originCity: 'Bursa',
        originDistrict: 'Osmangazi',
        destinationCity: 'İzmir',
        destinationDistrict: 'Kemalpaşa',
        cargoType: 'Tekstil',
        pickupCarrier: true,
        pickupShipper: true,
        oLat: 40.188,
        oLng: 29.061,
        dLat: 38.419,
        dLng: 27.129,
      ),
      DemoConstants.jobCompletedId: mkJob(
        id: DemoConstants.jobCompletedId,
        status: JobStatus.completed,
        title: 'Adana → Mersin gıda',
        acceptedOfferId: DemoConstants.offerAcceptedCompletedId,
        originCity: 'Adana',
        originDistrict: 'Seyhan',
        destinationCity: 'Mersin',
        destinationDistrict: 'Tarsus',
        cargoType: 'Gıda',
        weightTons: 8,
        pickupCarrier: true,
        pickupShipper: true,
        deliveryCarrier: true,
        deliveryShipper: true,
        oLat: 37.000,
        oLng: 35.321,
        dLat: 36.812,
        dLng: 34.641,
      ),
    };

    Offer mkOffer({
      required String id,
      required String jobId,
      required OfferStatus status,
      required double price,
    }) =>
        Offer(
          id: id,
          jobPostId: jobId,
          carrierId: DemoConstants.carrierId,
          price: price,
          status: status,
          createdAt: now.subtract(const Duration(hours: 5)),
          carrierName: carrier.fullName,
          carrierRating: carrier.ratingAvg,
          carrierCompletedJobs: carrier.completedJobsCount,
        );

    final offers = {
      DemoConstants.offerPendingId: mkOffer(
        id: DemoConstants.offerPendingId,
        jobId: DemoConstants.jobOpenId,
        status: OfferStatus.pending,
        price: 19500,
      ),
      DemoConstants.offerAcceptedPickupId: mkOffer(
        id: DemoConstants.offerAcceptedPickupId,
        jobId: DemoConstants.jobPickupId,
        status: OfferStatus.accepted,
        price: 14000,
      ),
      DemoConstants.offerAcceptedOnRoadId: mkOffer(
        id: DemoConstants.offerAcceptedOnRoadId,
        jobId: DemoConstants.jobOnRoadId,
        status: OfferStatus.accepted,
        price: 16500,
      ),
      DemoConstants.offerAcceptedCompletedId: mkOffer(
        id: DemoConstants.offerAcceptedCompletedId,
        jobId: DemoConstants.jobCompletedId,
        status: OfferStatus.accepted,
        price: 8500,
      ),
    };

    final threadPickup = MessageThread(
      id: DemoConstants.threadPickupId,
      jobPostId: DemoConstants.jobPickupId,
      shipperId: DemoConstants.shipperId,
      carrierId: DemoConstants.carrierId,
      lastMessageAt: now.subtract(const Duration(minutes: 20)),
      lastMessageBody: 'Yükleme saatinde orada olacağım.',
      jobTitle: jobs[DemoConstants.jobPickupId]!.title,
      counterpartName: carrier.fullName,
    );
    final threadOnRoad = MessageThread(
      id: DemoConstants.threadOnRoadId,
      jobPostId: DemoConstants.jobOnRoadId,
      shipperId: DemoConstants.shipperId,
      carrierId: DemoConstants.carrierId,
      lastMessageAt: now.subtract(const Duration(minutes: 5)),
      lastMessageBody: 'Yola çıktım, tahmini 4 saat.',
      unreadCount: 1,
      jobTitle: jobs[DemoConstants.jobOnRoadId]!.title,
      counterpartName: shipper.fullName,
    );

    final pings =
        _seedPings(DemoConstants.jobOnRoadId, jobs[DemoConstants.jobOnRoadId]!);

    final reviews = [
      Review(
        id: 'demo-review-1',
        jobPostId: DemoConstants.jobCompletedId,
        reviewerId: DemoConstants.shipperId,
        revieweeId: DemoConstants.carrierId,
        rating: 5,
        comment: 'Zamanında ve sorunsuz teslim.',
        createdAt: now.subtract(const Duration(days: 3)),
        reviewerName: shipper.fullName,
      ),
    ];

    return DemoAppState(
      profiles: {
        DemoConstants.shipperId: shipper,
        DemoConstants.carrierId: carrier,
      },
      carrierProfiles: {DemoConstants.carrierId: carrierProfile},
      jobs: jobs,
      offers: offers,
      threads: {
        DemoConstants.threadPickupId: threadPickup,
        DemoConstants.threadOnRoadId: threadOnRoad,
      },
      messagesByThread: {
        DemoConstants.threadPickupId: [
          Message(
            id: 'demo-msg-1',
            threadId: DemoConstants.threadPickupId,
            senderId: DemoConstants.carrierId,
            body: 'Yükleme saatinde orada olacağım.',
            isRead: true,
            createdAt: now.subtract(const Duration(minutes: 20)),
          ),
        ],
        DemoConstants.threadOnRoadId: [
          Message(
            id: 'demo-msg-2',
            threadId: DemoConstants.threadOnRoadId,
            senderId: DemoConstants.carrierId,
            body: 'Yola çıktım, tahmini 4 saat.',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
        ],
      },
      notificationsByUser: {
        DemoConstants.shipperId: [
          AppNotification(
            id: 'demo-notif-s1',
            userId: DemoConstants.shipperId,
            type: NotificationType.jobStatusChanged,
            title: 'Yük yolda',
            body: 'Bursa → İzmir taşıması devam ediyor.',
            data: {'job_post_id': DemoConstants.jobOnRoadId},
            isRead: false,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
        DemoConstants.carrierId: [
          AppNotification(
            id: 'demo-notif-c1',
            userId: DemoConstants.carrierId,
            type: NotificationType.offerAccepted,
            title: 'Teklifin kabul edildi',
            body: 'Kocaeli → Eskişehir ilanı için teklifin onaylandı.',
            data: {'job_post_id': DemoConstants.jobPickupId},
            isRead: false,
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      },
      reviews: reviews,
      pingsByJob: {DemoConstants.jobOnRoadId: pings},
    );
  }

  static List<LocationPing> _seedPings(String jobId, JobPost job) {
    final oLat = job.originLat ?? 40.0;
    final oLng = job.originLng ?? 29.0;
    final dLat = job.destinationLat ?? 39.0;
    final dLng = job.destinationLng ?? 32.0;
    final pings = <LocationPing>[];
    final now = DateTime.now();
    for (var i = 0; i < 8; i++) {
      final t = i / 7.0;
      pings.add(
        LocationPing(
          id: i + 1,
          jobPostId: jobId,
          carrierId: DemoConstants.carrierId,
          lat: oLat + (dLat - oLat) * t,
          lng: oLng + (dLng - oLng) * t,
          speedKmh: 72 + Random().nextDouble() * 8,
          recordedAt: now.subtract(Duration(minutes: (7 - i) * 12)),
        ),
      );
    }
    return pings;
  }

  // --- Mutations (RPC taklidi) ---

  JobPost createJob(JobPostInput input, String shipperId) {
    final coords = DemoCityCoords.forRoute(
      input.originCity,
      input.destinationCity,
    );
    final id = _uuid.v4();
    final job = JobPost(
      id: id,
      shipperId: shipperId,
      title: input.title,
      description: input.description,
      cargoType: input.cargoType,
      weightTons: input.weightTons,
      volumeM3: input.volumeM3,
      originCity: input.originCity,
      originDistrict: input.originDistrict,
      destinationCity: input.destinationCity,
      destinationDistrict: input.destinationDistrict,
      originAddress: input.originAddress,
      destinationAddress: input.destinationAddress,
      originLat: input.originLat ?? coords.$1,
      originLng: input.originLng ?? coords.$2,
      destinationLat: input.destinationLat ?? coords.$3,
      destinationLng: input.destinationLng ?? coords.$4,
      pickupDate: input.pickupDate,
      deliveryDate: input.deliveryDate,
      preferredTrailerType: input.preferredTrailerType,
      budgetMin: input.budgetMin,
      budgetMax: input.budgetMax,
      createdAt: DateTime.now(),
    );
    _setJob(job);
    _emit();
    return job;
  }

  void cancelJob(String id, String reason) {
    final j = _state.jobs[id];
    if (j == null) return;
    _setJob(
      JobPost(
        id: j.id,
        shipperId: j.shipperId,
        title: j.title,
        description: j.description,
        cargoType: j.cargoType,
        weightTons: j.weightTons,
        volumeM3: j.volumeM3,
        originCity: j.originCity,
        originDistrict: j.originDistrict,
        destinationCity: j.destinationCity,
        destinationDistrict: j.destinationDistrict,
        originAddress: j.originAddress,
        destinationAddress: j.destinationAddress,
        originLat: j.originLat,
        originLng: j.originLng,
        destinationLat: j.destinationLat,
        destinationLng: j.destinationLng,
        pickupDate: j.pickupDate,
        deliveryDate: j.deliveryDate,
        preferredTrailerType: j.preferredTrailerType,
        budgetMin: j.budgetMin,
        budgetMax: j.budgetMax,
        status: JobStatus.cancelled,
        acceptedOfferId: j.acceptedOfferId,
        pickupConfirmedByCarrier: j.pickupConfirmedByCarrier,
        pickupConfirmedByShipper: j.pickupConfirmedByShipper,
        deliveryConfirmedByCarrier: j.deliveryConfirmedByCarrier,
        deliveryConfirmedByShipper: j.deliveryConfirmedByShipper,
        createdAt: j.createdAt,
        cancelledAt: DateTime.now(),
        cancelledReason: reason.isEmpty ? 'İptal edildi' : reason,
      ),
    );
    _emit();
  }

  Offer createOffer({
    required String jobPostId,
    required String carrierId,
    required double price,
    String? message,
  }) {
    final carrier = _state.profiles[carrierId]!;
    final id = _uuid.v4();
    final offer = Offer(
      id: id,
      jobPostId: jobPostId,
      carrierId: carrierId,
      price: price,
      message: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
      carrierName: carrier.fullName,
      carrierRating: carrier.ratingAvg,
      carrierCompletedJobs: carrier.completedJobsCount,
    );
    final offers = Map<String, Offer>.from(_state.offers)..[id] = offer;
    _state = _state.copyWith(offers: offers);
    final job = _state.jobs[jobPostId];
    if (job != null) {
      _notifyUser(
        job.shipperId,
        NotificationType.newOffer,
        'Yeni teklif',
        '${carrier.fullName} ${price.toStringAsFixed(0)} ₺ teklif verdi.',
        data: {'job_post_id': jobPostId, 'offer_id': id},
      );
    }
    _emit();
    return offer;
  }

  void acceptOffer(String offerId) {
    final offer = _state.offers[offerId];
    if (offer == null) return;
    final jobId = offer.jobPostId;
    final job = _state.jobs[jobId];
    if (job == null || !job.status.isOpen) return;

    final offers = Map<String, Offer>.from(_state.offers);
    for (final e in offers.entries) {
      if (e.value.jobPostId == jobId && e.value.status == OfferStatus.pending) {
        offers[e.key] = Offer(
          id: e.value.id,
          jobPostId: e.value.jobPostId,
          carrierId: e.value.carrierId,
          price: e.value.price,
          message: e.value.message,
          status:
              e.key == offerId ? OfferStatus.accepted : OfferStatus.rejected,
          createdAt: e.value.createdAt,
          carrierName: e.value.carrierName,
          carrierRating: e.value.carrierRating,
          carrierCompletedJobs: e.value.carrierCompletedJobs,
        );
      }
    }
    _state = _state.copyWith(offers: offers);

    _setJob(
      JobPost(
        id: job.id,
        shipperId: job.shipperId,
        title: job.title,
        description: job.description,
        cargoType: job.cargoType,
        weightTons: job.weightTons,
        volumeM3: job.volumeM3,
        originCity: job.originCity,
        originDistrict: job.originDistrict,
        destinationCity: job.destinationCity,
        destinationDistrict: job.destinationDistrict,
        originAddress: job.originAddress,
        destinationAddress: job.destinationAddress,
        originLat: job.originLat,
        originLng: job.originLng,
        destinationLat: job.destinationLat,
        destinationLng: job.destinationLng,
        pickupDate: job.pickupDate,
        deliveryDate: job.deliveryDate,
        preferredTrailerType: job.preferredTrailerType,
        budgetMin: job.budgetMin,
        budgetMax: job.budgetMax,
        status: JobStatus.offerAccepted,
        acceptedOfferId: offerId,
        createdAt: job.createdAt,
      ),
    );

    final threadId = _uuid.v4();
    final thread = MessageThread(
      id: threadId,
      jobPostId: jobId,
      shipperId: job.shipperId,
      carrierId: offer.carrierId,
      jobTitle: job.title,
      counterpartName: _state.profiles[offer.carrierId]?.fullName,
    );
    final threads = Map<String, MessageThread>.from(_state.threads)
      ..[threadId] = thread;
    _state = _state.copyWith(threads: threads);

    final payment = PaymentRecord(
      id: 'pay-$jobId',
      jobPostId: jobId,
      offerId: offer.id,
      shipperId: job.shipperId,
      carrierId: offer.carrierId,
      amount: offer.price,
      commissionAmount: 0,
      carrierPayout: offer.price,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
    );
    _state = _state.copyWith(
      paymentsByJob: {..._state.paymentsByJob, jobId: payment},
    );

    _notifyUser(
      offer.carrierId,
      NotificationType.offerAccepted,
      'Teklifin kabul edildi',
      'Yükveren teklifini onayladı.',
      data: {'job_post_id': jobId, 'offer_id': offerId},
    );
    _emit();
  }

  void rejectOffer(String offerId) {
    final offer = _state.offers[offerId];
    if (offer == null) return;
    final offers = Map<String, Offer>.from(_state.offers);
    final o = offers[offerId]!;
    offers[offerId] = Offer(
      id: o.id,
      jobPostId: o.jobPostId,
      carrierId: o.carrierId,
      price: o.price,
      message: o.message,
      status: OfferStatus.rejected,
      createdAt: o.createdAt,
      carrierName: o.carrierName,
      carrierRating: o.carrierRating,
      carrierCompletedJobs: o.carrierCompletedJobs,
    );
    _state = _state.copyWith(offers: offers);
    _notifyUser(
      offer.carrierId,
      NotificationType.offerRejected,
      'Teklifin reddedildi',
      'Yükveren teklifini reddetti.',
      data: {'job_post_id': offer.jobPostId},
    );
    _emit();
  }

  void withdrawOffer(String offerId) {
    final offers = Map<String, Offer>.from(_state.offers);
    final o = offers[offerId];
    if (o == null) return;
    offers[offerId] = Offer(
      id: o.id,
      jobPostId: o.jobPostId,
      carrierId: o.carrierId,
      price: o.price,
      message: o.message,
      status: OfferStatus.withdrawn,
      createdAt: o.createdAt,
      carrierName: o.carrierName,
      carrierRating: o.carrierRating,
      carrierCompletedJobs: o.carrierCompletedJobs,
    );
    _state = _state.copyWith(offers: offers);
    _emit();
  }

  void confirmPickup(String jobId, String callerId) {
    var job = _state.jobs[jobId];
    if (job == null) return;
    final offer = job.acceptedOfferId != null
        ? _state.offers[job.acceptedOfferId!]
        : null;
    if (offer == null) return;

    final isShipper = job.shipperId == callerId;
    final isCarrier = offer.carrierId == callerId;
    if (!isShipper && !isCarrier) return;

    var status = job.status;
    if (status == JobStatus.offerAccepted) {
      status = JobStatus.pickupApproval;
    }

    var pickupShipper = job.pickupConfirmedByShipper;
    var pickupCarrier = job.pickupConfirmedByCarrier;
    if (isShipper) pickupShipper = true;
    if (isCarrier) pickupCarrier = true;

    if (pickupShipper && pickupCarrier) {
      status = JobStatus.loaded;
    }

    job = JobPost(
      id: job.id,
      shipperId: job.shipperId,
      title: job.title,
      description: job.description,
      cargoType: job.cargoType,
      weightTons: job.weightTons,
      volumeM3: job.volumeM3,
      originCity: job.originCity,
      originDistrict: job.originDistrict,
      destinationCity: job.destinationCity,
      destinationDistrict: job.destinationDistrict,
      originAddress: job.originAddress,
      destinationAddress: job.destinationAddress,
      originLat: job.originLat,
      originLng: job.originLng,
      destinationLat: job.destinationLat,
      destinationLng: job.destinationLng,
      pickupDate: job.pickupDate,
      deliveryDate: job.deliveryDate,
      preferredTrailerType: job.preferredTrailerType,
      budgetMin: job.budgetMin,
      budgetMax: job.budgetMax,
      status: status,
      acceptedOfferId: job.acceptedOfferId,
      pickupConfirmedByCarrier: pickupCarrier,
      pickupConfirmedByShipper: pickupShipper,
      deliveryConfirmedByCarrier: job.deliveryConfirmedByCarrier,
      deliveryConfirmedByShipper: job.deliveryConfirmedByShipper,
      createdAt: job.createdAt,
    );
    _setJob(job);

    if (!(pickupShipper && pickupCarrier)) {
      final otherId = isShipper ? offer.carrierId : job.shipperId;
      _notifyUser(
        otherId,
        NotificationType.jobStatusChanged,
        'Yük alma onayı bekleniyor',
        'Karşı taraf yük almayı onayladı, sen de onayla.',
        data: {'job_post_id': jobId},
      );
    }
    _emit();
  }

  void startRoad(String jobId, String callerId) {
    final job = _state.jobs[jobId];
    final offer = job?.acceptedOfferId != null
        ? _state.offers[job!.acceptedOfferId!]
        : null;
    if (job == null || offer == null || offer.carrierId != callerId) return;
    if (job.status != JobStatus.loaded) return;

    _setJob(
      JobPost(
        id: job.id,
        shipperId: job.shipperId,
        title: job.title,
        description: job.description,
        cargoType: job.cargoType,
        weightTons: job.weightTons,
        volumeM3: job.volumeM3,
        originCity: job.originCity,
        originDistrict: job.originDistrict,
        destinationCity: job.destinationCity,
        destinationDistrict: job.destinationDistrict,
        originAddress: job.originAddress,
        destinationAddress: job.destinationAddress,
        originLat: job.originLat,
        originLng: job.originLng,
        destinationLat: job.destinationLat,
        destinationLng: job.destinationLng,
        pickupDate: job.pickupDate,
        deliveryDate: job.deliveryDate,
        preferredTrailerType: job.preferredTrailerType,
        budgetMin: job.budgetMin,
        budgetMax: job.budgetMax,
        status: JobStatus.onRoad,
        acceptedOfferId: job.acceptedOfferId,
        pickupConfirmedByCarrier: job.pickupConfirmedByCarrier,
        pickupConfirmedByShipper: job.pickupConfirmedByShipper,
        deliveryConfirmedByCarrier: job.deliveryConfirmedByCarrier,
        deliveryConfirmedByShipper: job.deliveryConfirmedByShipper,
        createdAt: job.createdAt,
      ),
    );
    _state = _state.copyWith(
      pingsByJob: {
        ..._state.pingsByJob,
        jobId: _seedPings(jobId, _state.jobs[jobId]!),
      },
    );
    _notifyUser(
      job.shipperId,
      NotificationType.jobStatusChanged,
      'Yük yolda',
      'Nakliyeci yola çıktı.',
      data: {'job_post_id': jobId},
    );
    _emit();
  }

  void confirmDelivery(String jobId, String callerId) {
    var job = _state.jobs[jobId];
    if (job == null) return;
    final offer = job.acceptedOfferId != null
        ? _state.offers[job.acceptedOfferId!]
        : null;
    if (offer == null) return;

    final isShipper = job.shipperId == callerId;
    final isCarrier = offer.carrierId == callerId;
    if (!isShipper && !isCarrier) return;

    var status = job.status;
    if (status == JobStatus.onRoad) status = JobStatus.deliveryApproval;

    var deliveryShipper = job.deliveryConfirmedByShipper;
    var deliveryCarrier = job.deliveryConfirmedByCarrier;
    if (isShipper) deliveryShipper = true;
    if (isCarrier) deliveryCarrier = true;

    if (deliveryShipper && deliveryCarrier) {
      status = JobStatus.awaitingPayment;
    }

    job = JobPost(
      id: job.id,
      shipperId: job.shipperId,
      title: job.title,
      description: job.description,
      cargoType: job.cargoType,
      weightTons: job.weightTons,
      volumeM3: job.volumeM3,
      originCity: job.originCity,
      originDistrict: job.originDistrict,
      destinationCity: job.destinationCity,
      destinationDistrict: job.destinationDistrict,
      originAddress: job.originAddress,
      destinationAddress: job.destinationAddress,
      originLat: job.originLat,
      originLng: job.originLng,
      destinationLat: job.destinationLat,
      destinationLng: job.destinationLng,
      pickupDate: job.pickupDate,
      deliveryDate: job.deliveryDate,
      preferredTrailerType: job.preferredTrailerType,
      budgetMin: job.budgetMin,
      budgetMax: job.budgetMax,
      status: status,
      acceptedOfferId: job.acceptedOfferId,
      pickupConfirmedByCarrier: job.pickupConfirmedByCarrier,
      pickupConfirmedByShipper: job.pickupConfirmedByShipper,
      deliveryConfirmedByCarrier: deliveryCarrier,
      deliveryConfirmedByShipper: deliveryShipper,
      createdAt: job.createdAt,
    );
    _setJob(job);

    if (status == JobStatus.awaitingPayment) {
      final pay = _state.paymentsByJob[jobId];
      if (pay != null) {
        _state = _state.copyWith(
          paymentsByJob: {
            ..._state.paymentsByJob,
            jobId: PaymentRecord(
              id: pay.id,
              jobPostId: pay.jobPostId,
              offerId: pay.offerId,
              shipperId: pay.shipperId,
              carrierId: pay.carrierId,
              amount: pay.amount,
              commissionAmount: 0,
              carrierPayout: pay.carrierPayout,
              status: PaymentStatus.awaitingTransfer,
              createdAt: pay.createdAt,
            ),
          },
        );
      }
      _notifyUser(
        job.shipperId,
        NotificationType.paymentPending,
        'Ödeme bekleniyor',
        'Nakliyecinin IBAN bilgisine havale yapabilirsin.',
        data: {'job_post_id': jobId},
      );
      _notifyUser(
        offer.carrierId,
        NotificationType.paymentPending,
        'Ödeme bekleniyor',
        'Yükveren ödemeyi yaptığında onayla.',
        data: {'job_post_id': jobId},
      );
    }
    _emit();
  }

  PaymentRecord? paymentForJob(String jobId) => _state.paymentsByJob[jobId];

  void confirmCarrierPayment(String jobId, String callerId) {
    final job = _state.jobs[jobId];
    if (job == null || job.status != JobStatus.awaitingPayment) return;
    final offer = job.acceptedOfferId != null
        ? _state.offers[job.acceptedOfferId!]
        : null;
    if (offer == null || offer.carrierId != callerId) return;

    final pay = _state.paymentsByJob[jobId];
    if (pay != null) {
      _state = _state.copyWith(
        paymentsByJob: {
          ..._state.paymentsByJob,
          jobId: PaymentRecord(
            id: pay.id,
            jobPostId: pay.jobPostId,
            offerId: pay.offerId,
            shipperId: pay.shipperId,
            carrierId: pay.carrierId,
            amount: pay.amount,
            commissionAmount: 0,
            carrierPayout: pay.carrierPayout,
            status: PaymentStatus.carrierConfirmed,
            createdAt: pay.createdAt,
            releasedAt: DateTime.now(),
          ),
        },
      );
    }

    _setJob(
      JobPost(
        id: job.id,
        shipperId: job.shipperId,
        title: job.title,
        description: job.description,
        cargoType: job.cargoType,
        weightTons: job.weightTons,
        volumeM3: job.volumeM3,
        originCity: job.originCity,
        originDistrict: job.originDistrict,
        destinationCity: job.destinationCity,
        destinationDistrict: job.destinationDistrict,
        originAddress: job.originAddress,
        destinationAddress: job.destinationAddress,
        originLat: job.originLat,
        originLng: job.originLng,
        destinationLat: job.destinationLat,
        destinationLng: job.destinationLng,
        pickupDate: job.pickupDate,
        deliveryDate: job.deliveryDate,
        preferredTrailerType: job.preferredTrailerType,
        budgetMin: job.budgetMin,
        budgetMax: job.budgetMax,
        status: JobStatus.completed,
        acceptedOfferId: job.acceptedOfferId,
        pickupConfirmedByCarrier: job.pickupConfirmedByCarrier,
        pickupConfirmedByShipper: job.pickupConfirmedByShipper,
        deliveryConfirmedByCarrier: job.deliveryConfirmedByCarrier,
        deliveryConfirmedByShipper: job.deliveryConfirmedByShipper,
        createdAt: job.createdAt,
      ),
    );

    final profiles = Map<String, UserProfile>.from(_state.profiles);
    for (final uid in [job.shipperId, offer.carrierId]) {
      final p = profiles[uid];
      if (p != null) {
        profiles[uid] = p.copyWith(
          completedJobsCount: p.completedJobsCount + 1,
        );
      }
    }
    _state = _state.copyWith(profiles: profiles);

    _notifyUser(
      job.shipperId,
      NotificationType.paymentConfirmed,
      'Ödeme onaylandı',
      'Nakliyeci ödemeyi aldığını onayladı. İş tamamlandı.',
      data: {'job_post_id': jobId},
    );
    _notifyUser(
      offer.carrierId,
      NotificationType.jobStatusChanged,
      'İş tamamlandı',
      'Taşıma başarıyla tamamlandı.',
      data: {'job_post_id': jobId},
    );
    _emit();
  }

  void reportShipperTransfer(String jobId, String callerId) {
    final job = _state.jobs[jobId];
    if (job == null || job.shipperId != callerId) return;
    if (job.status != JobStatus.awaitingPayment) return;

    final pay = _state.paymentsByJob[jobId];
    if (pay == null) return;

    _state = _state.copyWith(
      paymentsByJob: {
        ..._state.paymentsByJob,
        jobId: PaymentRecord(
          id: pay.id,
          jobPostId: pay.jobPostId,
          offerId: pay.offerId,
          shipperId: pay.shipperId,
          carrierId: pay.carrierId,
          amount: pay.amount,
          commissionAmount: 0,
          carrierPayout: pay.carrierPayout,
          status: pay.status,
          createdAt: pay.createdAt,
          shipperReportedTransferAt: DateTime.now(),
        ),
      },
    );

    _notifyUser(
      pay.carrierId,
      NotificationType.paymentPending,
      'Ödeme bildirimi',
      'Yükveren ödemeyi yaptığını bildirdi. Lütfen kontrol edip onayla.',
      data: {'job_post_id': jobId},
    );
    _emit();
  }

  void releasePaymentEscrow(String jobId) {
    final pay = _state.paymentsByJob[jobId];
    if (pay == null || pay.status != PaymentStatus.held) return;
    _state = _state.copyWith(
      paymentsByJob: {
        ..._state.paymentsByJob,
        jobId: PaymentRecord(
          id: pay.id,
          jobPostId: pay.jobPostId,
          offerId: pay.offerId,
          shipperId: pay.shipperId,
          carrierId: pay.carrierId,
          amount: pay.amount,
          commissionAmount: pay.commissionAmount,
          carrierPayout: pay.carrierPayout,
          status: PaymentStatus.released,
          createdAt: pay.createdAt,
          releasedAt: DateTime.now(),
        ),
      },
    );
    _emit();
  }

  void addPing(String jobId, double lat, double lng) {
    final list = List<LocationPing>.from(_state.pingsByJob[jobId] ?? []);
    list.add(
      LocationPing(
        id: list.length + 1,
        jobPostId: jobId,
        carrierId: DemoConstants.carrierId,
        lat: lat,
        lng: lng,
        speedKmh: 70,
        recordedAt: DateTime.now(),
      ),
    );
    _state = _state.copyWith(
      pingsByJob: {..._state.pingsByJob, jobId: list},
    );
    _emit();
  }

  Review addReview({
    required String jobPostId,
    required String reviewerId,
    required String revieweeId,
    required int rating,
    String? comment,
  }) {
    final reviewer = _state.profiles[reviewerId];
    final review = Review(
      id: _uuid.v4(),
      jobPostId: jobPostId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      reviewerName: reviewer?.fullName,
    );
    _state = _state.copyWith(reviews: [..._state.reviews, review]);
    _notifyUser(
      revieweeId,
      NotificationType.reviewReceived,
      'Yeni değerlendirme',
      '$rating yıldız aldın.',
      data: {'job_post_id': jobPostId},
    );
    _emit();
    return review;
  }

  UserProfile upsertProfile(UserProfile profile) {
    final profiles = Map<String, UserProfile>.from(_state.profiles)
      ..[profile.id] = profile;
    _state = _state.copyWith(profiles: profiles);
    _emit();
    return profile;
  }

  CarrierProfile upsertCarrierProfile(CarrierProfile profile) {
    final map = Map<String, CarrierProfile>.from(_state.carrierProfiles)
      ..[profile.userId] = profile;
    _state = _state.copyWith(carrierProfiles: map);
    _emit();
    return profile;
  }

  JobPost updateJob(JobPost job) {
    _setJob(job);
    _emit();
    return job;
  }

  List<Message> messagesForThread(String threadId) =>
      _state.messagesByThread[threadId] ?? [];

  Message appendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) {
    final msg = Message(
      id: _uuid.v4(),
      threadId: threadId,
      senderId: senderId,
      body: body,
      isRead: false,
      createdAt: DateTime.now(),
    );
    final byThread = Map<String, List<Message>>.from(_state.messagesByThread);
    final list = List<Message>.from(byThread[threadId] ?? [])..add(msg);
    byThread[threadId] = list;

    final thread = _state.threads[threadId];
    Map<String, MessageThread>? threads;
    if (thread != null) {
      threads = Map<String, MessageThread>.from(_state.threads);
      threads[threadId] = thread.copyWith(
        lastMessageAt: msg.createdAt,
        lastMessageBody: body,
      );
      final otherId = thread.counterpartId(senderId);
      _notifyUser(
        otherId,
        NotificationType.newMessage,
        'Yeni mesaj',
        body,
        data: {'thread_id': threadId, 'job_post_id': thread.jobPostId},
      );
    }

    _state = _state.copyWith(
      messagesByThread: byThread,
      threads: threads ?? _state.threads,
    );
    _emit();
    return msg;
  }

  void updateNotifications(String userId, List<AppNotification> list) {
    _state = _state.copyWith(
      notificationsByUser: {..._state.notificationsByUser, userId: list},
    );
    _emit();
  }

  void markThreadMessagesRead(String threadId) {
    final byThread = Map<String, List<Message>>.from(_state.messagesByThread);
    final list = byThread[threadId];
    if (list == null) return;
    byThread[threadId] = list.map((m) => m.copyWith(isRead: true)).toList();
    final threads = Map<String, MessageThread>.from(_state.threads);
    final t = threads[threadId];
    if (t != null) {
      threads[threadId] = t.copyWith(unreadCount: 0);
    }
    _state = _state.copyWith(
      messagesByThread: byThread,
      threads: threads,
    );
    _emit();
  }
}

/// Demo ilan oluştururken şehir → koordinat (geocoding API yok).
class DemoCityCoords {
  DemoCityCoords._();

  static (double, double, double, double) forRoute(
    String originCity,
    String destinationCity,
  ) {
    final o = _coords[originCity] ?? (41.01, 28.97);
    final d = _coords[destinationCity] ?? (39.93, 32.86);
    return (o.$1, o.$2, d.$1, d.$2);
  }

  static const _coords = <String, (double, double)>{
    'İstanbul': (41.0082, 28.9784),
    'Ankara': (39.9334, 32.8597),
    'İzmir': (38.4192, 27.1287),
    'Bursa': (40.1885, 29.0610),
    'Kocaeli': (40.7654, 29.9408),
    'Eskişehir': (39.7767, 30.5206),
    'Adana': (37.0000, 35.3213),
    'Mersin': (36.8121, 34.6415),
    'Antalya': (36.8969, 30.7133),
    'Gaziantep': (37.0662, 37.3833),
    'Trabzon': (41.0027, 39.7168),
    'Kars': (40.6013, 43.0975),
    'Van': (38.5012, 43.3730),
    'Samsun': (41.2867, 36.3300),
    'Diyarbakır': (37.9144, 40.2306),
    'Konya': (37.8746, 32.4932),
    'Kayseri': (38.7254, 35.4833),
  };
}
