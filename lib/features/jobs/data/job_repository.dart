import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasima_app/core/constants.dart';
import 'package:uuid/uuid.dart';

class JobPhotoUploadResult {
  final String publicUrl;
  final String storagePath;
  const JobPhotoUploadResult({
    required this.publicUrl,
    required this.storagePath,
  });
}

class JobPost {
  final String id;
  final String shipperId;
  final CargoType cargoType;
  final VehicleType vehicleType;
  final String? cargoDescription;
  final String pickupCity;
  final String pickupDistrict;
  final String deliveryCity;
  final String deliveryDistrict;
  final String pickupDate;
  final String? pickupTimeWindow;
  final bool isDateFlexible;
  final UrgencyLevel urgencyLevel;
  final String? extraNotes;
  final JobStatus status;
  final String? acceptedOfferId;
  final String? cancelledReason;
  final String createdAt;
  final String updatedAt;

  const JobPost({
    required this.id,
    required this.shipperId,
    required this.cargoType,
    this.vehicleType = VehicleType.diger,
    this.cargoDescription,
    required this.pickupCity,
    required this.pickupDistrict,
    required this.deliveryCity,
    required this.deliveryDistrict,
    required this.pickupDate,
    this.pickupTimeWindow,
    this.isDateFlexible = false,
    this.urgencyLevel = UrgencyLevel.normal,
    this.extraNotes,
    this.status = JobStatus.open,
    this.acceptedOfferId,
    this.cancelledReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPost.fromMap(Map<String, dynamic> map) {
    return JobPost(
      id: map['id'] as String,
      shipperId: map['shipper_id'] as String,
      cargoType: (map['cargo_type'] as String).toCargoType(),
      vehicleType: (map['vehicle_type'] as String? ?? 'diger').toVehicleType(),
      cargoDescription: map['cargo_description'] as String?,
      pickupCity: map['pickup_city'] as String,
      pickupDistrict: map['pickup_district'] as String,
      deliveryCity: map['delivery_city'] as String,
      deliveryDistrict: map['delivery_district'] as String,
      pickupDate: map['pickup_date'] as String,
      pickupTimeWindow: map['pickup_time_window'] as String?,
      isDateFlexible: map['is_date_flexible'] as bool? ?? false,
      urgencyLevel: (map['urgency_level'] as String? ?? 'normal').toUrgencyLevel(),
      extraNotes: map['extra_notes'] as String?,
      status: (map['status'] as String? ?? 'open').toJobStatus(),
      acceptedOfferId: map['accepted_offer_id'] as String?,
      cancelledReason: map['cancelled_reason'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}

class JobPhoto {
  final String id;
  final String jobPostId;
  final String photoUrl;
  final String? storagePath;

  const JobPhoto({
    required this.id,
    required this.jobPostId,
    required this.photoUrl,
    this.storagePath,
  });

  factory JobPhoto.fromMap(Map<String, dynamic> map) {
    return JobPhoto(
      id: map['id'] as String,
      jobPostId: map['job_post_id'] as String,
      photoUrl: map['photo_url'] as String,
      storagePath: map['storage_path'] as String?,
    );
  }
}

class JobPrivateInfo {
  final String pickupAddress;
  final String? deliveryAddress;

  const JobPrivateInfo({required this.pickupAddress, this.deliveryAddress});

  factory JobPrivateInfo.fromMap(Map<String, dynamic> map) {
    return JobPrivateInfo(
      pickupAddress: map['pickup_address'] as String? ?? '',
      deliveryAddress: map['delivery_address'] as String?,
    );
  }
}

class JobRepository {
  SupabaseClient get _client => SupabaseClientManager.instance.client;
  final _uuid = const Uuid();

  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<String> createJobPost({
    required CargoType cargoType,
    required VehicleType vehicleType,
    String? cargoDescription,
    required String pickupCity,
    required String pickupDistrict,
    required String deliveryCity,
    required String deliveryDistrict,
    required String pickupDate,
    String? pickupTimeWindow,
    bool isDateFlexible = false,
    String urgencyLevel = 'normal',
    String? extraNotes,
  }) async {
    if (DevAuthService.isActive) {
      final now = DateTime.now().toIso8601String();
      final jobPostId = _uuid.v4();
      await DevAuthService.upsertJob({
        'id': jobPostId,
        'shipper_id': _userId,
        'cargo_type': cargoType.name,
        'vehicle_type': vehicleType.name,
        'cargo_description': cargoDescription,
        'pickup_city': pickupCity,
        'pickup_district': pickupDistrict,
        'delivery_city': deliveryCity,
        'delivery_district': deliveryDistrict,
        'pickup_date': pickupDate,
        'pickup_time_window': pickupTimeWindow,
        'is_date_flexible': isDateFlexible,
        'urgency_level': urgencyLevel,
        'extra_notes': extraNotes,
        'status': 'open',
        'accepted_offer_id': null,
        'cancelled_reason': null,
        'created_at': now,
        'updated_at': now,
      });
      await DevAuthService.upsertOffer({
        'id': _uuid.v4(),
        'job_post_id': jobPostId,
        'carrier_id': DevAuthService.demoCarrierId,
        'amount': 18500.0,
        'currency': 'TRY',
        'note': 'Demo teklif: sigortalı taşıma, aynı gün teslim.',
        'available_at': pickupDate,
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
      });
      return jobPostId;
    }

    final response = await _client
        .from('job_posts')
        .insert({
          'shipper_id': _userId,
          'cargo_type': cargoType.name,
          'vehicle_type': vehicleType.name,
          'cargo_description': cargoDescription,
          'pickup_city': pickupCity,
          'pickup_district': pickupDistrict,
          'delivery_city': deliveryCity,
          'delivery_district': deliveryDistrict,
          'pickup_date': pickupDate,
          'pickup_time_window': pickupTimeWindow,
          'is_date_flexible': isDateFlexible,
          'urgency_level': urgencyLevel,
          'extra_notes': extraNotes,
          'status': 'open',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> createJobPrivateInfo({
    required String jobPostId,
    String? pickupAddress,
    String? deliveryAddress,
  }) async {
    if (DevAuthService.isActive) {
      await DevAuthService.saveJobPrivateInfo({
        'job_post_id': jobPostId,
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
      });
      return;
    }

    await _client.from('job_private_info').insert({
      'job_post_id': jobPostId,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
    });
  }

  Future<JobPhotoUploadResult> uploadJobPhoto({
    required String jobPostId,
    required String filePath,
  }) async {
    if (DevAuthService.isActive) {
      debugPrint(
        'DEV demo: fotoğraf yükleme Supabase Storage kullanmadan geçildi.',
      );
      return JobPhotoUploadResult(publicUrl: filePath, storagePath: filePath);
    }

    final ext = filePath.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final storagePath = '$_userId/$jobPostId/$fileName';

    await _client.storage
        .from('job-photos')
        .upload(storagePath, File(filePath));
    final publicUrl = _client.storage
        .from('job-photos')
        .getPublicUrl(storagePath);
    return JobPhotoUploadResult(publicUrl: publicUrl, storagePath: storagePath);
  }

  Future<void> addJobPhotoRecord({
    required String jobPostId,
    required String photoUrl,
    required String storagePath,
  }) async {
    if (DevAuthService.isActive) return;

    await _client.from('job_photos').insert({
      'job_post_id': jobPostId,
      'photo_url': photoUrl,
      'storage_path': storagePath,
    });
  }

  Future<String> createJobWithDetails({
    required CargoType cargoType,
    required VehicleType vehicleType,
    String? cargoDescription,
    required String pickupCity,
    required String pickupDistrict,
    required String deliveryCity,
    required String deliveryDistrict,
    required String pickupDate,
    String? pickupTimeWindow,
    bool isDateFlexible = false,
    String urgencyLevel = 'normal',
    String? extraNotes,
    String? pickupAddress,
    String? deliveryAddress,
    List<String>? photoPaths,
  }) async {
    final jobPostId = await createJobPost(
      cargoType: cargoType,
      vehicleType: vehicleType,
      cargoDescription: cargoDescription,
      pickupCity: pickupCity,
      pickupDistrict: pickupDistrict,
      deliveryCity: deliveryCity,
      deliveryDistrict: deliveryDistrict,
      pickupDate: pickupDate,
      pickupTimeWindow: pickupTimeWindow,
      isDateFlexible: isDateFlexible,
      urgencyLevel: urgencyLevel,
      extraNotes: extraNotes,
    );

    await createJobPrivateInfo(
      jobPostId: jobPostId,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
    );

    if (photoPaths != null) {
      for (final path in photoPaths) {
        try {
          final result = await uploadJobPhoto(
            jobPostId: jobPostId,
            filePath: path,
          );
          await addJobPhotoRecord(
            jobPostId: jobPostId,
            photoUrl: result.publicUrl,
            storagePath: result.storagePath,
          );
        } catch (e) {
          rethrow;
        }
      }
    }

    return jobPostId;
  }

  Future<List<JobPost>> getMyJobPosts({int? limit}) async {
    if (DevAuthService.isActive) {
      final jobs =
          (await DevAuthService.getJobs())
              .where((j) => j['shipper_id'] == _userId)
              .map(JobPost.fromMap)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return limit == null ? jobs : jobs.take(limit).toList();
    }

    var query = _client
        .from('job_posts')
        .select()
        .eq('shipper_id', _userId)
        .order('created_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(
      response,
    ).map(JobPost.fromMap).toList();
  }

  Future<List<JobPost>> getOpenJobPostsForCarrier({
    String? city,
    String? cargoType,
    String? urgency,
    String? carrierVehicleType,
  }) async {
    if (DevAuthService.isActive) {
      var jobs = (await DevAuthService.getJobs()).where(
        (j) => j['status'] == 'open' && j['shipper_id'] != _userId,
      );
      if (city != null && city.isNotEmpty) {
        final lower = city.toLowerCase();
        jobs = jobs.where(
          (j) =>
              j['pickup_city'].toString().toLowerCase().contains(lower) ||
              j['delivery_city'].toString().toLowerCase().contains(lower),
        );
      }
      if (cargoType != null && cargoType.isNotEmpty) {
        jobs = jobs.where((j) => j['cargo_type'] == cargoType);
      }
      if (urgency != null && urgency.isNotEmpty) {
        jobs = jobs.where((j) => j['urgency_level'] == urgency);
      }
      if (carrierVehicleType != null && carrierVehicleType.isNotEmpty) {
        jobs = jobs.where((j) =>
            j['vehicle_type'] == carrierVehicleType ||
            j['vehicle_type'] == 'diger' ||
            j['vehicle_type'] == null);
      }
      final list = jobs.map(JobPost.fromMap).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    dynamic query = _client
        .from('job_posts')
        .select()
        .eq('status', 'open')
        .order('created_at', ascending: false);

    if (city != null && city.isNotEmpty) {
      query = (query as dynamic).or(
        'pickup_city.ilike.%$city%,delivery_city.ilike.%$city%',
      );
    }
    if (cargoType != null && cargoType.isNotEmpty) {
      query = (query as dynamic).eq('cargo_type', cargoType);
    }
    if (urgency != null && urgency.isNotEmpty) {
      query = (query as dynamic).eq('urgency_level', urgency);
    }
    if (carrierVehicleType != null && carrierVehicleType.isNotEmpty) {
      query = (query as dynamic).or(
        'vehicle_type.eq.$carrierVehicleType,vehicle_type.eq.diger',
      );
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(
      response,
    ).map(JobPost.fromMap).toList();
  }

  Future<JobPost?> getJobPostById(String jobPostId) async {
    if (DevAuthService.isActive) {
      final job = await DevAuthService.getJob(jobPostId);
      return job == null ? null : JobPost.fromMap(job);
    }

    final response = await _client
        .from('job_posts')
        .select()
        .eq('id', jobPostId)
        .maybeSingle();
    if (response == null) return null;
    return JobPost.fromMap(response);
  }

  Future<List<JobPhoto>> getJobPhotos(String jobPostId) async {
    if (DevAuthService.isActive) return [];

    final response = await _client
        .from('job_photos')
        .select()
        .eq('job_post_id', jobPostId);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(JobPhoto.fromMap).toList();
  }

  Future<JobPrivateInfo?> getJobPrivateInfoForOwner(String jobPostId) async {
    if (DevAuthService.isActive) {
      final response = await DevAuthService.getJobPrivateInfo(jobPostId);
      return response == null ? null : JobPrivateInfo.fromMap(response);
    }

    final response = await _client
        .from('job_private_info')
        .select()
        .eq('job_post_id', jobPostId)
        .maybeSingle();
    if (response == null) return null;
    return JobPrivateInfo.fromMap(response);
  }

  Future<void> startJob(String jobPostId) async {
    if (DevAuthService.isActive) {
      final job = await DevAuthService.getJob(jobPostId);
      if (job == null) throw StateError('İlan bulunamadı.');
      job['status'] = 'in_progress';
      job['updated_at'] = DateTime.now().toIso8601String();
      await DevAuthService.upsertJob(job);
      await DevAuthService.addNotification({
        'id': _uuid.v4(),
        'user_id': DevAuthService.devUserId,
        'title': 'Taşıma Başladı',
        'body': 'Demo taşıma süreci başlatıldı.',
        'type': 'status_change',
        'related_job_id': jobPostId,
        'related_offer_id': null,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    await _client.rpc('start_job', params: {'p_job_post_id': jobPostId});
  }

  Future<void> completeJob(String jobPostId) async {
    if (DevAuthService.isActive) {
      final job = await DevAuthService.getJob(jobPostId);
      if (job == null) throw StateError('İlan bulunamadı.');
      job['status'] = 'completed';
      job['updated_at'] = DateTime.now().toIso8601String();
      await DevAuthService.upsertJob(job);
      await DevAuthService.addNotification({
        'id': _uuid.v4(),
        'user_id': DevAuthService.devUserId,
        'title': 'İş Tamamlandı',
        'body': 'Demo iş tamamlandı. Değerlendirme yapabilirsiniz.',
        'type': 'status_change',
        'related_job_id': jobPostId,
        'related_offer_id': null,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    await _client.rpc('complete_job', params: {'p_job_post_id': jobPostId});
  }

  Future<void> cancelJob(String jobPostId, {String? reason}) async {
    if (DevAuthService.isActive) {
      final job = await DevAuthService.getJob(jobPostId);
      if (job == null) throw StateError('İlan bulunamadı.');
      job['status'] = 'cancelled';
      job['cancelled_reason'] = reason ?? 'Kullanıcı tarafından iptal edildi.';
      job['updated_at'] = DateTime.now().toIso8601String();
      await DevAuthService.upsertJob(job);
      return;
    }

    await _client.rpc(
      'cancel_job',
      params: {
        'p_job_post_id': jobPostId,
        'p_reason': reason ?? 'Kullanıcı tarafından iptal edildi.',
      },
    );
  }
}
