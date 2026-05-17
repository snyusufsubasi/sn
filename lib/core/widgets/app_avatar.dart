import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';

/// ARACIYOK avatar bileşeni.
///
/// Profil fotoğrafı varsa onu, yoksa ilk harf gösterir.
/// Her kullanıcı için hash bazında farklı bir arka plan rengi.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = AppAvatarSize.md,
    this.onTap,
  });

  /// Kullanıcının adı (ilk harf için)
  final String? name;

  /// Profil fotoğrafı URL'si
  final String? imageUrl;

  /// Boyut
  final AppAvatarSize size;

  /// Tıklanabilir
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimension = _dimension(size);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar;
    if (hasImage) {
      avatar = CircleAvatar(
        radius: dimension / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
      );
    } else {
      avatar = CircleAvatar(
        radius: dimension / 2,
        backgroundColor: _bgColor(name ?? ''),
        child: Text(
          _initial(name ?? '?'),
          style: TextStyle(
            fontSize: dimension * 0.42,
            fontWeight: FontWeight.w600,
            color: const Color(AppPalette.white),
          ),
        ),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(dimension),
        child: avatar,
      );
    }
    return avatar;
  }

  double _dimension(AppAvatarSize s) {
    switch (s) {
      case AppAvatarSize.xs:
        return 32;
      case AppAvatarSize.sm:
        return 40;
      case AppAvatarSize.md:
        return 48;
      case AppAvatarSize.lg:
        return 56;
      case AppAvatarSize.xl:
        return 72;
    }
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    // İlk harf + varsa ikinci kelimenin ilk harfi
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Color _bgColor(String name) {
    if (name.isEmpty) return const Color(AppPalette.navy500);
    // Kullanıcı adından hash bazlı renk
    final hash = name.codeUnits.fold<int>(0, (prev, c) => prev + c);
    final colors = _avatarColors;
    return colors[hash % colors.length];
  }

  static const _avatarColors = [
    Color(AppPalette.navy600),
    Color(AppPalette.navy700),
    Color(AppPalette.amber500),
    Color(AppPalette.green600),
    Color(AppPalette.blue600),
    Color(AppPalette.red600),
    Color(AppPalette.navy800),
    Color(AppPalette.gold600),
  ];
}

enum AppAvatarSize { xs, sm, md, lg, xl }
