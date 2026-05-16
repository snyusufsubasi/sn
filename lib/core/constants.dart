// ignore_for_file: constant_identifier_names

enum UserRole { shipper, carrier }

enum JobStatus { open, offer_accepted, in_progress, completed, cancelled }

enum OfferStatus { pending, accepted, rejected, withdrawn, expired }

enum CargoType {
  ev_esyasi,
  parca_esya,
  paletli_urun,
  insaat_malzemesi,
  makine,
  mobilya,
  gida_disi,
  diger,
}

enum VehicleType {
  panelvan,
  kamyonet,
  on_teker,
  kirkayak,
  tir,
  diger,
}

enum UrgencyLevel { normal, urgent, very_urgent }

enum UserType { individual, company }

enum ReportReason {
  sahte_ilan,
  yanlis_bilgi,
  uygunsuz_davranis,
  odeme_anlasmazligi,
  diger,
}

extension JobStatusExtension on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.open:
        return 'Teklif Bekliyor';
      case JobStatus.offer_accepted:
        return 'Nakliyeci Seçildi';
      case JobStatus.in_progress:
        return 'Taşıma Devam Ediyor';
      case JobStatus.completed:
        return 'Tamamlandı';
      case JobStatus.cancelled:
        return 'iptal edildi';
    }
  }
}

extension OfferStatusExtension on OfferStatus {
  String get label {
    switch (this) {
      case OfferStatus.pending:
        return 'Beklemede';
      case OfferStatus.accepted:
        return 'Kabul Edildi';
      case OfferStatus.rejected:
        return 'Reddedildi';
      case OfferStatus.withdrawn:
        return 'Geri Çekildi';
      case OfferStatus.expired:
        return 'Süresi Doldu';
    }
  }
}

extension CargoTypeExtension on CargoType {
  String get label {
    switch (this) {
      case CargoType.ev_esyasi:
        return 'Ev Eşyası';
      case CargoType.parca_esya:
        return 'Parça Eşya';
      case CargoType.paletli_urun:
        return 'Paletli Ürün';
      case CargoType.insaat_malzemesi:
        return 'İnşaat Malzemesi';
      case CargoType.makine:
        return 'Makine';
      case CargoType.mobilya:
        return 'Mobilya';
      case CargoType.gida_disi:
        return 'Gıda Hariç Ürün';
      case CargoType.diger:
        return 'Diğer';
    }
  }
}

extension VehicleTypeExtension on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.panelvan: return 'Panelvan (1.5 - 2 Ton)';
      case VehicleType.kamyonet: return 'Kamyonet (3 - 4 Ton)';
      case VehicleType.on_teker: return '10 Teker Kamyon (15 Ton)';
      case VehicleType.kirkayak: return 'Kırkayak (20 Ton)';
      case VehicleType.tir: return 'Tır (25 Ton +)';
      case VehicleType.diger: return 'Fark Etmez / Diğer';
    }
  }
}

extension ReportReasonExtension on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.sahte_ilan:
        return 'Sahte İlan';
      case ReportReason.yanlis_bilgi:
        return 'Yanlış Bilgi';
      case ReportReason.uygunsuz_davranis:
        return 'Uygunsuz Davranış';
      case ReportReason.odeme_anlasmazligi:
        return 'Ödeme Anlaşmazlığı';
      case ReportReason.diger:
        return 'Diğer';
    }
  }
}

extension EnumParsing on String {
  CargoType toCargoType() => CargoType.values.firstWhere(
      (e) => e.name == this,
      orElse: () => CargoType.diger);
      
  JobStatus toJobStatus() => JobStatus.values.firstWhere(
      (e) => e.name == this,
      orElse: () => JobStatus.open);
      
  UrgencyLevel toUrgencyLevel() => UrgencyLevel.values.firstWhere(
      (e) => e.name == this,
      orElse: () => UrgencyLevel.normal);
      
  OfferStatus toOfferStatus() => OfferStatus.values.firstWhere(
      (e) => e.name == this,
      orElse: () => OfferStatus.pending);

  VehicleType toVehicleType() => VehicleType.values.firstWhere(
      (e) => e.name == this,
      orElse: () => VehicleType.diger);
}
