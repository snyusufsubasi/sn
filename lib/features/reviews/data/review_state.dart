import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasima_app/features/reviews/data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});
