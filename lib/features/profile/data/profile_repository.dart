import 'package:flutter/foundation.dart';
import 'package:tasima_app/core/dev_auth_service.dart';
import 'package:tasima_app/data/supabase_client.dart';

class ProfileRepository {
  get _client => SupabaseClientManager.instance.client;

  String get _userId => DevAuthService.isActive
      ? DevAuthService.devUserId
      : _client.auth.currentUser!.id;

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    if (DevAuthService.isActive) return DevAuthService.getBaseProfile();
    return await _client
        .from('profiles')
        .select()
        .eq('id', _client.auth.currentUser!.id)
        .maybeSingle();
  }

  Future<String?> getCurrentUserRole() async {
    if (DevAuthService.isActive) return DevAuthService.getRole();
    final r = await _client
        .from('profiles')
        .select('role')
        .eq('id', _client.auth.currentUser!.id)
        .maybeSingle();
    return r?['role'] as String?;
  }

  Future<void> setRole(String role) async {
    if (DevAuthService.isActive) {
      await DevAuthService.saveRole(role);
      return;
    }
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Oturum bulunamadı. Rol seçimi için önce giriş yapın.');
    }
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (e, st) {
      debugPrint('PROFILE SET ROLE ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> upsertBaseProfile({
    required String fullName,
    required String city,
    required String district,
  }) async {
    if (DevAuthService.isActive) {
      await DevAuthService.saveBaseProfile(
        fullName: fullName,
        city: city,
        district: district,
      );
      return;
    }
    await _client.from('profiles').upsert({
      'id': _client.auth.currentUser!.id,
      'full_name': fullName,
      'city': city,
      'district': district,
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertPrivatePhone(String phone) async {
    if (DevAuthService.isActive) {
      await DevAuthService.savePhone(phone);
      return;
    }
    await _client.from('profile_private_info').upsert({
      'user_id': _client.auth.currentUser!.id,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertShipperProfile({
    String? companyName,
    required String userType,
  }) async {
    if (DevAuthService.isActive) {
      await DevAuthService.saveShipperProfile(userType: userType);
      return;
    }
    await _client.from('shipper_profiles').upsert({
      'id': _client.auth.currentUser!.id,
      'company_name': companyName,
      'user_type': userType,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertCarrierProfile({
    String? companyName,
    required String vehicleType,
    required String capacityText,
    required List<String> serviceAreas,
    required List<String> jobTypePreferences,
  }) async {
    if (DevAuthService.isActive) {
      await DevAuthService.saveCarrierProfile(
        vehicleType: vehicleType,
        capacityText: capacityText,
        serviceAreas: serviceAreas,
        jobTypePreferences: jobTypePreferences,
      );
      return;
    }
    await _client.from('carrier_profiles').upsert({
      'id': _client.auth.currentUser!.id,
      'company_name': companyName,
      'vehicle_type': vehicleType,
      'capacity_text': capacityText,
      'service_areas': serviceAreas,
      'job_type_preferences': jobTypePreferences,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertCarrierPrivateInfo(String plateNumber) async {
    if (DevAuthService.isActive) {
      await DevAuthService.savePlate(plateNumber);
      return;
    }
    await _client.from('carrier_private_info').upsert({
      'carrier_id': _client.auth.currentUser!.id,
      'plate_number': plateNumber,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isProfileSetupComplete() async {
    if (DevAuthService.isActive) return DevAuthService.isProfileSetupComplete();
    try {
      final userId = _client.auth.currentUser!.id;
      final profile = await _client
          .from('profiles')
          .select('role, full_name, city, district')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return false;
      final role = profile['role'] as String?;
      final fullName = profile['full_name'] as String?;
      final city = profile['city'] as String?;
      final district = profile['district'] as String?;
      if (role == null || role.isEmpty) return false;
      if (fullName == null || fullName.isEmpty) return false;
      if (city == null || city.isEmpty) return false;
      if (district == null || district.isEmpty) return false;
      if (role == 'shipper') {
        final s = await _client
            .from('shipper_profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle();
        if (s == null) return false;
        final p = await _client
            .from('profile_private_info')
            .select('user_id')
            .eq('user_id', userId)
            .maybeSingle();
        if (p == null) return false;
      } else if (role == 'carrier') {
        final c = await _client
            .from('carrier_profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle();
        if (c == null) return false;
        final p = await _client
            .from('profile_private_info')
            .select('user_id')
            .eq('user_id', userId)
            .maybeSingle();
        if (p == null) return false;
        final pl = await _client
            .from('carrier_private_info')
            .select('carrier_id')
            .eq('carrier_id', userId)
            .maybeSingle();
        if (pl == null) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getShipperProfile() async {
    if (DevAuthService.isActive) return DevAuthService.getShipperProfile();
    return await _client
        .from('shipper_profiles')
        .select()
        .eq('id', _userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getCarrierProfile() async {
    if (DevAuthService.isActive) return DevAuthService.getCarrierProfile();
    return await _client
        .from('carrier_profiles')
        .select()
        .eq('id', _userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getPrivatePhone() async {
    if (DevAuthService.isActive) return DevAuthService.getPhoneData();
    return await _client
        .from('profile_private_info')
        .select('phone')
        .eq('user_id', _userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getCarrierPlate() async {
    if (DevAuthService.isActive) return DevAuthService.getCarrierPlate();
    return await _client
        .from('carrier_private_info')
        .select('plate_number')
        .eq('carrier_id', _userId)
        .maybeSingle();
  }
}
