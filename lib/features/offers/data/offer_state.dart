import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/features/offers/data/offer_repository.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepository();
});

final jobOffersProvider = FutureProvider.family<List<OfferWithCarrier>, String>(
  (ref, jobPostId) async {
    return ref.watch(offerRepositoryProvider).getOffersForJob(jobPostId);
  },
);

final myOfferForJobProvider = FutureProvider.family<Offer?, String>((
  ref,
  jobPostId,
) async {
  return ref.watch(offerRepositoryProvider).getMyOfferForJob(jobPostId);
});
