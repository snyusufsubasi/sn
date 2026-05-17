import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';

/// İlan kartlarında kullanılan mini rota görseli.
///
/// compact=false (varsayılan):
/// ```text
/// ● İstanbul, Pendik
/// ║
/// ║
/// 📍 Ankara, Çankaya
/// ```
///
/// compact=true:
/// ```text
/// ● İstanbul → 📍 Ankara
/// ```
class MiniRouteWidget extends StatelessWidget {
  const MiniRouteWidget({
    required this.originCity,
    required this.destinationCity,
    this.originDistrict,
    this.destinationDistrict,
    this.compact = false,
    super.key,
  });

  /// Başlangıç şehri.
  final String originCity;

  /// Bitiş şehri.
  final String destinationCity;

  /// Başlangıç ilçesi (opsiyonel).
  final String? originDistrict;

  /// Bitiş ilçesi (opsiyonel).
  final String? destinationDistrict;

  /// Tek satır "● İstanbul → 📍 Ankara" formatı.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact() : _buildExpanded();
  }

  /// Tek satır: ● İstanbul → 📍 Ankara
  Widget _buildCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 10, color: Color(AppPalette.navy800)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          originCity,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(AppPalette.ink800),
          ),
        ),
        const SizedBox(width: AppSpacing.quarks),
        Text(
          '→',
          style: TextStyle(
            fontSize: 13,
            color: const Color(AppPalette.ink400),
          ),
        ),
        const SizedBox(width: AppSpacing.quarks),
        const Icon(Icons.location_on,
            size: 14, color: Color(AppPalette.amber500)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          destinationCity,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(AppPalette.ink800),
          ),
        ),
      ],
    );
  }

  /// Dikey: ● İstanbul, Pendik ║ ║ 📍 Ankara, Çankaya
  Widget _buildExpanded() {
    // İkon kolon genişliğini sabitle — circle (10px) ve pin (16px) hizalansın
    const iconColumnWidth = 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlangıç satırı
        _buildLocationRow(
          icon: const Icon(Icons.circle,
              size: 10, color: Color(AppPalette.navy800)),
          iconColumnWidth: iconColumnWidth,
          city: originCity,
          district: originDistrict,
        ),
        // Dikey çizgi (2px, navy200)
        SizedBox(
          height: AppSpacing.xl,
          child: Row(
            children: [
              SizedBox(
                width: iconColumnWidth,
                child: Center(
                  child: Container(
                    width: 2,
                    height: AppSpacing.xl,
                    color: const Color(AppPalette.navy200),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
        // Bitiş satırı
        _buildLocationRow(
          icon: const Icon(Icons.location_on,
              size: 16, color: Color(AppPalette.amber500)),
          iconColumnWidth: iconColumnWidth,
          city: destinationCity,
          district: destinationDistrict,
        ),
      ],
    );
  }

  /// Bir lokasyon satırı: [icon] [city] [district (küçük)]
  Widget _buildLocationRow({
    required Widget icon,
    required double iconColumnWidth,
    required String city,
    String? district,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: iconColumnWidth, child: Center(child: icon)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          city,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(AppPalette.ink800),
          ),
        ),
        if (district != null && district.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.quarks),
          Text(
            ', $district',
            style: const TextStyle(
              fontSize: 11,
              color: Color(AppPalette.ink500),
            ),
          ),
        ],
      ],
    );
  }
}
