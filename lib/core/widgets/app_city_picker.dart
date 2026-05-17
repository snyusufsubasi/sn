import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';

/// Türkiye şehir seçici bottom sheet.
///
/// Kullanım:
/// ```dart
/// final city = await AppCityPicker.show(context);
/// if (city != null) { /* kullanıcı {city} seçti */ }
/// ```
class AppCityPicker {
  AppCityPicker._();

  /// Bottom sheet açar, seçilen şehir adını döndürür.
  static Future<String?> show(
    BuildContext context, {
    List<String>? recentCities,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: const Color(AppPalette.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: _CityPickerBody(recentCities: recentCities),
          ),
        );
      },
    );
  }
}

/// Bölge adı ve altındaki şehirler.
class _RegionData {
  const _RegionData({required this.name, required this.cities});

  final String name;
  final List<String> cities;
}

/// Türkiye'nin 7 coğrafi bölgesi ve 81 ili.
const _regions = <_RegionData>[
  _RegionData(
    name: 'Marmara',
    cities: [
      'İstanbul',
      'Bursa',
      'Kocaeli',
      'Balıkesir',
      'Tekirdağ',
      'Çanakkale',
      'Edirne',
      'Kırklareli',
      'Yalova',
      'Sakarya',
      'Bilecik',
    ],
  ),
  _RegionData(
    name: 'Ege',
    cities: [
      'İzmir',
      'Manisa',
      'Aydın',
      'Denizli',
      'Muğla',
      'Afyonkarahisar',
      'Kütahya',
      'Uşak',
    ],
  ),
  _RegionData(
    name: 'Akdeniz',
    cities: [
      'Antalya',
      'Mersin',
      'Adana',
      'Hatay',
      'Isparta',
      'Burdur',
      'Kahramanmaraş',
      'Osmaniye',
    ],
  ),
  _RegionData(
    name: 'İç Anadolu',
    cities: [
      'Ankara',
      'Konya',
      'Kayseri',
      'Eskişehir',
      'Sivas',
      'Kırşehir',
      'Nevşehir',
      'Niğde',
      'Aksaray',
      'Karaman',
      'Kırıkkale',
      'Yozgat',
      'Çankırı',
    ],
  ),
  _RegionData(
    name: 'Karadeniz',
    cities: [
      'Samsun',
      'Trabzon',
      'Ordu',
      'Giresun',
      'Rize',
      'Artvin',
      'Sinop',
      'Kastamonu',
      'Bartın',
      'Karabük',
      'Zonguldak',
      'Düzce',
      'Bolu',
      'Çorum',
      'Amasya',
      'Tokat',
      'Gümüşhane',
      'Bayburt',
    ],
  ),
  _RegionData(
    name: 'Doğu Anadolu',
    cities: [
      'Erzurum',
      'Van',
      'Malatya',
      'Elazığ',
      'Erzincan',
      'Ağrı',
      'Kars',
      'Muş',
      'Bitlis',
      'Bingöl',
      'Hakkari',
      'Ardahan',
      'Iğdır',
      'Tunceli',
    ],
  ),
  _RegionData(
    name: 'Güneydoğu Anadolu',
    cities: [
      'Gaziantep',
      'Diyarbakır',
      'Şanlıurfa',
      'Mardin',
      'Adıyaman',
      'Batman',
      'Siirt',
      'Şırnak',
      'Kilis',
    ],
  ),
];

class _CityPickerBody extends StatefulWidget {
  const _CityPickerBody({this.recentCities});

  final List<String>? recentCities;

  @override
  State<_CityPickerBody> createState() => _CityPickerBodyState();
}

class _CityPickerBodyState extends State<_CityPickerBody> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  final Set<String> _expandedRegions = {};
  bool _showRecent = true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<_RegionData> get _filteredRegions {
    if (_query.isEmpty) return _regions;
    final lowerQuery = _query.toLowerCase();
    return _regions.map((region) {
      final matchedCities = region.cities
          .where((c) => c.toLowerCase().contains(lowerQuery))
          .toList();
      return _RegionData(name: region.name, cities: matchedCities);
    }).where((r) => r.cities.isNotEmpty).toList();
  }

  bool get _hasRecent =>
      widget.recentCities != null && widget.recentCities!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final showRecent = _hasRecent && _showRecent && _query.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header: Başlık + kapat ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Şehir Seç',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 22),
              ),
            ],
          ),
        ),

        // ── Arama Kutusu ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Inter',
              color: Color(AppPalette.ink900),
            ),
            decoration: InputDecoration(
              hintText: 'Şehir ara...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                        setState(() => _query = '');
                      },
                      child: const Icon(Icons.clear, size: 20),
                    )
                  : null,
              filled: true,
              fillColor: const Color(AppPalette.ink100),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: Color(AppPalette.ink200),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: Color(AppPalette.navy800),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Liste ────────────────────────────────────────────────
        Flexible(
          child: _filteredRegions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.huge,
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: Center(
                    child: Text(
                      'Aramanızla eşleşen şehir bulunamadı.',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(AppPalette.ink500),
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  shrinkWrap: true,
                  children: [
                    // Son kullanılanlar
                    if (showRecent) ...[
                      _buildRecentSection(context),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: Divider(
                          height: 1,
                          color: Color(AppPalette.ink200),
                        ),
                      ),
                    ],

                    // Bölgeler
                    ..._filteredRegions.map(
                      (region) => _RegionTile(
                        region: region,
                        isExpanded:
                            _expandedRegions.contains(region.name),
                        query: _query,
                        onToggle: () {
                          setState(() {
                            if (_expandedRegions.contains(region.name)) {
                              _expandedRegions.remove(region.name);
                            } else {
                              _expandedRegions.add(region.name);
                            }
                          });
                        },
                        onSelect: (city) =>
                            Navigator.of(context).pop(city),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final cities = widget.recentCities!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                'Son Kullanılanlar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(AppPalette.ink500),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showRecent = false),
                child: Text(
                  'Gizle',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(AppPalette.navy800),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...cities.map(
          (city) => _CityRow(
            city: city,
            onTap: () => Navigator.of(context).pop(city),
          ),
        ),
      ],
    );
  }
}

/// Genişletilebilir bölge başlığı (AnimatedCrossFade).
class _RegionTile extends StatefulWidget {
  const _RegionTile({
    required this.region,
    required this.isExpanded,
    required this.query,
    required this.onToggle,
    required this.onSelect,
  });

  final _RegionData region;
  final bool isExpanded;
  final String query;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  State<_RegionTile> createState() => _RegionTileState();
}

class _RegionTileState extends State<_RegionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.isExpanded) _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(_RegionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _animationController.forward();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = widget.query.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bölge başlık satırı ──────────────────────────────────
        InkWell(
          onTap: hasActiveFilter ? null : widget.onToggle,
          splashColor: const Color(AppPalette.navy50),
          highlightColor: const Color(AppPalette.navy50),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Ok ikonu
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 1.5708, // 90°
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: hasActiveFilter
                            ? const Color(AppPalette.ink300)
                            : const Color(AppPalette.navy800),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                // Bölge adı
                Text(
                  widget.region.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: hasActiveFilter
                        ? const Color(AppPalette.ink500)
                        : const Color(AppPalette.ink900),
                  ),
                ),
                const Spacer(),
                // Şehir sayısı
                Text(
                  '${widget.region.cities.length} il',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(AppPalette.ink500),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Genişletilebilir şehir listesi (AnimatedCrossFade) ──
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.region.cities.map(
              (city) => _CityRow(
                city: city,
                onTap: () => widget.onSelect(city),
              ),
            ).toList(),
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),

        // Bölgeler arası ince çizgi
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: Divider(height: 1, color: Color(AppPalette.ink200)),
        ),
      ],
    );
  }
}

/// Tek bir şehir satırı — scale micro animasyonlu.
class _CityRow extends StatefulWidget {
  const _CityRow({required this.city, required this.onTap});

  final String city;
  final VoidCallback onTap;

  @override
  State<_CityRow> createState() => _CityRowState();
}

class _CityRowState extends State<_CityRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: InkWell(
        onTap: _handleTap,
        splashColor: const Color(AppPalette.navy50),
        highlightColor: const Color(AppPalette.navy50),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            // icon (18) + spacing (sm 8 + md 12) = 38px indent
            horizontal: AppSpacing.pageHorizontal + 38,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.sm), // ok hizası
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(AppPalette.ink600),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.city,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(AppPalette.ink800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
