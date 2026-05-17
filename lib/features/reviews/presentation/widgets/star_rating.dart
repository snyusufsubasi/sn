import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 5 yıldız puanlama. Interactive ya da read-only.
class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating, super.key,
    this.onChanged,
    this.size = 28,
    this.color = AppColors.star,
  });

  /// 0..5 arası (read-only modda double, interactive'de int gibi davranır).
  final double rating;

  /// onChanged null ise read-only.
  final ValueChanged<int>? onChanged;
  final double size;
  final Color color;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final value = i + 1;
        final filled = value <= rating;
        final half = !filled && value - 0.5 <= rating;
        final icon = filled
            ? Icons.star
            : half
                ? Icons.star_half
                : Icons.star_border;
        final star = Icon(
          icon,
          size: size,
          color: filled || half ? color : AppColors.ink300,
        );
        if (!_interactive) {
          return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: star,
        );
        }
        return InkWell(
          onTap: () => onChanged!(value),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: star,
          ),
        );
      }),
    );
  }
}
