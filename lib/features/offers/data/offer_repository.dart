import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:uuid/uuid.dart';

class Offer {
  final String id;
  final String jobPostId;
  final String carrierId;
  final double amount;
  final String currency;
  final String? note;
  final String? availableAt;
  final String status;
  final String createdAt;
  final String updatedAt;

  const Offer({
    required this.id,
    required this.jobPostId,
    required this.carrierId,
    required this.amount,
    this.currency = 'TRY',
    this.note,
    this.availableAt,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as String,
      jobPostId: map['job_post_id'] as String,
      carrierId: map['carrier_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'TRY',
      note: map['note'] as String?,
      availableAt: map['available_at'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

class OfferWithCarrier {
  final Offer offer;
  final String carrierName;
  final String? vehicleType;
  final String? capacityText;
  final double? ratingAvg;
  final int? completedJobsCount;

  const OfferWithCarrier({
    required this.offer,
    required this.carrierName,
    this.vehicleType,
    this.capacityText,
    this.ratingAvg,
    this.completedJobsCount,
  });

  factory OfferWithCarrier.fromMap(Map<String, dynamic> map) {
    final profiles = map['profiles'] as Map<String, dynamic>?;
    final carrierProfiles = map['carrier_profiles'] as Map<String, dynamic>?;

    return OfferWithCarrier(
      offer: Offer.fromMap(map),
      carrierName: profiles?['full_name'] as String? ?? 'Bilinmiyor',
      vehicleType: carrierProfiles?['vehicle_type'] as String?,
      capacityText: carrierProfiles?['capacity_text'] as String?,
      ratingAvg: carrierProfiles?['rating_avg'] != null
          ? (carrierProfiles!['rating_avg'] as num).toDouble()
          : null,
      completedJobsCount: carrierProfiles?['completed_jobs_count'] as int?,
    );
  }
}

class OfferRepository {
  get _client => SupabaseClientManager.instance.client;
  final _uuid = const Uuid();

  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<Offer> createOffer({
    required String jobPostId,
    required double amount,
    String? note,
    String? availableAt,
  }) async {
    if (DevAuthService.isActive) {
      final existing = await getMyOfferForJob(jobPostId);
      if (existing != null &&
          (existing.status == 'pending' || existing.status == 'accepted')) {
        throw StateError('Bu ilana zaten aktif teklif verdiniz.');
      }
      final now = DateTime.now().toIso8601String();
      final offer = {
        'id': _uuid.v4(),
        'job_post_id': jobPostId,
        'carrier_id': _userId,
        'amount': amount,
        'currency': 'TRY',
        'note': note,
        'available_at': availableAt,
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
      };
      await DevAuthService.upsertOffer(offer);
      return Offer.fromMap(offer);
    }

    final response = await _client
        .from('offers')
        .insert({
          'job_post_id': jobPostId,
          'carrier_id': _userId,
          'amount': amount,
          'note': note,
          'available_at': availableAt,
          'status': 'pending',
        })
        .select()
        .single();

    return Offer.fromMap(response);
  }

  Future<Offer?> getMyOfferForJob(String jobPostId) async {
    if (DevAuthService.isActive) {
      final offers = await DevAuthService.getOffers();
      try {
        return Offer.fromMap(
          offers.firstWhere(
            (o) => o['job_post_id'] == jobPostId && o['carrier_id'] == _userId,
          ),
        );
      } catch (_) {
        return null;
      }
    }

    final response = await _client
        .from('offers')
        .select()
        .eq('job_post_id', jobPostId)
        .eq('carrier_id', _userId)
        .maybeSingle();
    if (response == null) return null;
    return Offer.fromMap(response);
  }

  Future<List<OfferWithCarrier>> getOffersForJob(String jobPostId) async {
    if (DevAuthService.isActive) {
      final offers =
          (await DevAuthService.getOffers())
              .where((o) => o['job_post_id'] == jobPostId)
              .toList()
            ..sort(
              (a, b) => b['created_at'].toString().compareTo(
                a['created_at'].toString(),
              ),
            );
      return offers.map((o) {
        final carrierId = o['carrier_id'] as String;
        final profile = carrierId == _userId
            ? {'full_name': 'Sizin nakliyeci profiliniz'}
            : {'full_name': 'Demo Nakliyeci'};
        return OfferWithCarrier.fromMap({
          ...o,
          'profiles': profile,
          'carrier_profiles': DevAuthService.demoCarrierPublicProfile(
            carrierId,
          ),
        });
      }).toList();
    }

    final response = await _client
        .from('offers')
        .select(
          '*, profiles!carrier_id(full_name), carrier_profiles!carrier_id(vehicle_type, capacity_text, rating_avg, completed_jobs_count)',
        )
        .eq('job_post_id', jobPostId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(OfferWithCarrier.fromMap).toList();
  }

  Future<Offer> updatePendingOffer({
    required String offerId,
    double? amount,
    String? note,
    String? availableAt,
  }) async {
    if (DevAuthService.isActive) {
      final offers = await DevAuthService.getOffers();
      final raw = offers.firstWhere((o) => o['id'] == offerId);
      if (raw['status'] != 'pending') {
        throw StateError('Sadece bekleyen teklif düzenlenebilir.');
      }
      if (amount != null) raw['amount'] = amount;
      if (note != null) raw['note'] = note;
      if (availableAt != null) raw['available_at'] = availableAt;
      raw['updated_at'] = DateTime.now().toIso8601String();
      await DevAuthService.upsertOffer(raw);
      return Offer.fromMap(raw);
    }

    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (amount != null) data['amount'] = amount;
    if (note != null) data['note'] = note;
    if (availableAt != null) data['available_at'] = availableAt;

    final response = await _client
        .from('offers')
        .update(data)
        .eq('id', offerId)
        .select()
        .single();
    return Offer.fromMap(response);
  }

  Future<void> withdrawOffer(String offerId) async {
    if (DevAuthService.isActive) {
      final offers = await DevAuthService.getOffers();
      final raw = offers.firstWhere(
        (o) => o['id'] == offerId && o['carrier_id'] == _userId,
      );
      raw['status'] = 'withdrawn';
      raw['updated_at'] = DateTime.now().toIso8601String();
      await DevAuthService.upsertOffer(raw);
      return;
    }

    await _client
        .from('offers')
        .update({
          'status': 'withdrawn',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', offerId)
        .eq('carrier_id', _userId);
  }

  Future<List<Offer>> getMyActiveOffers() async {
    if (DevAuthService.isActive) {
      return (await DevAuthService.getOffers())
          .where((o) => o['carrier_id'] == _userId)
          .map(Offer.fromMap)
          .toList();
    }

    final response = await _client
        .from('offers')
        .select()
        .eq('carrier_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(Offer.fromMap).toList();
  }

  Future<void> acceptOffer(String offerId) async {
    if (DevAuthService.isActive) {
      final offers = await DevAuthService.getOffers();
      final accepted = offers.firstWhere((o) => o['id'] == offerId);
      final jobId = accepted['job_post_id'] as String;
      for (final offer in offers.where((o) => o['job_post_id'] == jobId)) {
        offer['status'] = offer['id'] == offerId ? 'accepted' : 'rejected';
        offer['updated_at'] = DateTime.now().toIso8601String();
        await DevAuthService.upsertOffer(offer);
      }
      final job = await DevAuthService.getJob(jobId);
      if (job != null) {
        job['status'] = 'offer_accepted';
        job['accepted_offer_id'] = offerId;
        job['updated_at'] = DateTime.now().toIso8601String();
        await DevAuthService.upsertJob(job);
      }
      await DevAuthService.addNotification({
        'id': _uuid.v4(),
        'user_id': accepted['carrier_id'],
        'title': 'Teklif Kabul Edildi',
        'body': 'Demo ilanda teklifiniz kabul edildi.',
        'type': 'offer_accepted',
        'related_job_id': jobId,
        'related_offer_id': offerId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    await _client.rpc('accept_offer', params: {'p_offer_id': offerId});
  }

  Future<OfferWithCarrier?> getAcceptedOfferForJob(String jobPostId) async {
    if (DevAuthService.isActive) {
      final offers = await DevAuthService.getOffers();
      try {
        final raw = offers.firstWhere(
          (o) => o['job_post_id'] == jobPostId && o['status'] == 'accepted',
        );
        return OfferWithCarrier.fromMap({
          ...raw,
          'profiles': {
            'full_name': raw['carrier_id'] == _userId
                ? 'Sizin nakliyeci profiliniz'
                : 'Demo Nakliyeci',
          },
          'carrier_profiles': DevAuthService.demoCarrierPublicProfile(
            raw['carrier_id'] as String,
          ),
        });
      } catch (_) {
        return null;
      }
    }

    final response = await _client
        .from('offers')
        .select(
          '*, profiles!carrier_id(full_name), carrier_profiles!carrier_id(vehicle_type, capacity_text, rating_avg, completed_jobs_count)',
        )
        .eq('job_post_id', jobPostId)
        .eq('status', 'accepted')
        .maybeSingle();
    if (response == null) return null;
    return OfferWithCarrier.fromMap(response);
  }

  Future<Map<String, dynamic>?> getShipperContactInfo(String shipperId) async {
    if (DevAuthService.isActive) {
      final profile = await DevAuthService.getProfileForUser(shipperId);
      return {
        'full_name': profile?['full_name'] ?? 'Demo Y?k Veren',
        'phone': profile?['phone'] ?? '+905359398313',
      };
    }

    final phone = await _client
        .from('profile_private_info')
        .select('phone')
        .eq('user_id', shipperId)
        .maybeSingle();
    final profile = await _client
        .from('profiles')
        .select('full_name')
        .eq('id', shipperId)
        .single();
    return {'full_name': profile['full_name'], 'phone': phone?['phone']};
  }

  Future<Map<String, dynamic>?> getCarrierContactInfo(String carrierId) async {
    if (DevAuthService.isActive) {
      final profile = await DevAuthService.getProfileForUser(carrierId);
      return {
        'full_name': profile?['full_name'] ?? 'Demo Nakliyeci',
        'phone': profile?['phone'] ?? '+905359398313',
        'plate_number':
            profile?['plate_number'] ??
            (carrierId == _userId ? '34 DEV 001' : '34 DEMO 34'),
      };
    }

    final phone = await _client
        .from('profile_private_info')
        .select('phone')
        .eq('user_id', carrierId)
        .maybeSingle();
    final plate = await _client
        .from('carrier_private_info')
        .select('plate_number')
        .eq('carrier_id', carrierId)
        .maybeSingle();
    final profile = await _client
        .from('profiles')
        .select('full_name')
        .eq('id', carrierId)
        .single();
    return {
      'full_name': profile['full_name'],
      'phone': phone?['phone'],
      'plate_number': plate?['plate_number'],
    };
  }

  Future<Map<String, dynamic>?> getJobPrivateInfoForAccepted(
    String jobPostId,
  ) async {
    if (DevAuthService.isActive) {
      return DevAuthService.getJobPrivateInfo(jobPostId);
    }

    return await _client
        .from('job_private_info')
        .select('pickup_address, delivery_address')
        .eq('job_post_id', jobPostId)
        .maybeSingle();
  }
}
