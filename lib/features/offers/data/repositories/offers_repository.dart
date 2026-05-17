import '../../../../core/errors/result.dart';
import '../models/offer.dart';

abstract class OffersRepository {
  /// Belirli bir ilana gelen tüm teklifler (yükveren için).
  /// Carrier profile bilgisini de join eder.
  Future<Result<List<Offer>>> fetchOffersForJob(String jobId);

  /// Bu kullanıcının (carrier) belirli bir ilana verdiği teklif (varsa).
  Future<Result<Offer?>> fetchMyOfferForJob(String jobId);

  /// Bu kullanıcının (carrier) verdiği tüm teklifler.
  Future<Result<List<Offer>>> fetchMyOffers();

  /// Teklif oluştur.
  Future<Result<Offer>> createOffer({
    required String jobPostId,
    required double price,
    String? message,
  });

  /// Teklif kabul et (RPC: accept_offer).
  Future<Result<void>> acceptOffer(String offerId);

  /// Teklif reddet (RPC: reject_offer).
  Future<Result<void>> rejectOffer(String offerId);

  /// Teklifi geri çek.
  Future<Result<void>> withdrawOffer(String offerId);

  // Operasyon RPC'leri

  /// Çift taraflı yük alma onayı (RPC: confirm_pickup).
  Future<Result<void>> confirmPickup(String jobId);

  /// Nakliyeci yola çıktı (RPC: start_road).
  Future<Result<void>> startRoad(String jobId);

  /// Çift taraflı teslimat onayı (RPC: confirm_delivery).
  Future<Result<void>> confirmDelivery(String jobId);
}
