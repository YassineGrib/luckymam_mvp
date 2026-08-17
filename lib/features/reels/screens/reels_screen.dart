import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../ads/models/house_ad.dart';
import '../../ads/providers/ads_providers.dart';
import '../../ads/widgets/reel_ad_item.dart';
import '../models/reel_item.dart';
import '../providers/reels_provider.dart';
import '../widgets/reel_player.dart';
import '../widgets/reel_overlay.dart';

/// Full-screen TikTok-style vertical swipe reels screen with category filter.
class ReelsScreen extends ConsumerStatefulWidget {
  /// When set, opens the feed pre-filtered to reels tagged with any of
  /// these vaccine codes (deep link from a vaccine's fiche).
  final List<String>? initialVaccineCodes;

  /// Display label for the active vaccine filter badge (e.g. "ROR" or
  /// "Vaccins — 2 mois").
  final String? initialVaccineLabel;

  const ReelsScreen({
    super.key,
    this.initialVaccineCodes,
    this.initialVaccineLabel,
  });

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late PageController _pageController;
  bool _appliedVaccineFilter = false;
  String? _lastLoggedReelId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final vaccineCodes = widget.initialVaccineCodes;
    if (vaccineCodes != null && vaccineCodes.isNotEmpty) {
      _appliedVaccineFilter = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(selectedReelCategoryProvider.notifier).state =
            ReelCategory.vaccins;
        ref.read(selectedVaccineTagsProvider.notifier).state = vaccineCodes;
        final reels = ref.read(filteredReelsProvider);
        if (reels.isNotEmpty) _logReelViewFromVax(reels.first);
      });
    }
  }

  void _restoreReelsFilters() {
    if (!_appliedVaccineFilter) return;
    _appliedVaccineFilter = false;
    ref.read(selectedVaccineTagsProvider.notifier).state = null;
    ref.read(selectedReelCategoryProvider.notifier).state = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Jump to page 0 when category changes
  void _onCategoryChanged(ReelCategory? cat) {
    ref.read(selectedReelCategoryProvider.notifier).state = cat;
    // A manual category pick escapes the vaccine-scoped filter.
    ref.read(selectedVaccineTagsProvider.notifier).state = null;
    ref.read(currentReelIndexProvider.notifier).state = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _clearVaccineFilter() {
    ref.read(selectedVaccineTagsProvider.notifier).state = null;
    ref.read(currentReelIndexProvider.notifier).state = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _logReelViewFromVax(ReelItem reel) {
    final vaccineTags = ref.read(selectedVaccineTagsProvider);
    if (vaccineTags == null || vaccineTags.isEmpty) return;
    if (_lastLoggedReelId == reel.id) return;
    _lastLoggedReelId = reel.id;

    AnalyticsService().logEvent(
      'reel_view_from_vax',
      parameters: {'reel_id': reel.id, 'vaccine_codes': vaccineTags},
    );
  }

  @override
  Widget build(BuildContext context) {
    final reels = ref.watch(filteredReelsProvider);
    final currentIndex = ref.watch(currentReelIndexProvider);
    final selectedCategory = ref.watch(selectedReelCategoryProvider);
    final vaccineFilterActive = ref.watch(selectedVaccineTagsProvider) != null;

    // Interleave one sponsored item after every [adReelInterval] reels
    // (plan-gated: VIP gets an empty ad list, i.e. a pure feed).
    ref.watch(adsEnabledProvider);
    final reelAds = ref.read(adGateProvider).reelAds();
    final displayItems = <Object>[];
    var adCursor = 0;
    for (var i = 0; i < reels.length; i++) {
      displayItems.add(reels[i]);
      final isLast = i == reels.length - 1;
      if (reelAds.isNotEmpty && !isLast && (i + 1) % adReelInterval == 0) {
        displayItems.add(reelAds[adCursor % reelAds.length]);
        adCursor++;
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _restoreReelsFilters();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
            // ── Vertical page view ────────────────────────────────────
            displayItems.isEmpty
                ? _buildEmptyState()
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: displayItems.length,
                    onPageChanged: (index) {
                      ref.read(currentReelIndexProvider.notifier).state = index;
                      final item = displayItems[index];
                      if (item is ReelItem) _logReelViewFromVax(item);
                    },
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      if (item is HouseAd) {
                        return ReelAdItem(
                          ad: item,
                          isActive: currentIndex == index,
                        );
                      }
                      final reel = item as ReelItem;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ReelPlayer(
                            key: ValueKey(reel.id),
                            assetPath: reel.assetPath,
                            isActive: currentIndex == index,
                          ),
                          ReelOverlay(reel: reel),
                        ],
                      );
                    },
                  ),

            // ── Top bar ───────────────────────────────────────────────
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'مقاطع توعوية'
                              : Localizations.localeOf(context).languageCode == 'en'
                                  ? 'Educational Reels'
                                  : 'Reels Éducatifs',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Reel counter badge
                        if (displayItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.magentaPink.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${currentIndex + 1}/${displayItems.length}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Category filter chips ─────────────────────────────
                  _CategoryFilterBar(
                    selected: selectedCategory,
                    onSelected: _onCategoryChanged,
                  ),

                  // ── Vaccine filter badge (deep-link from a vaccine's fiche) ──
                  if (vaccineFilterActive && widget.initialVaccineLabel != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _clearVaccineFilter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.magentaPink.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.vaccines_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  Localizations.localeOf(context).languageCode == 'ar'
                                      ? 'تصفية: ${widget.initialVaccineLabel}'
                                      : Localizations.localeOf(context).languageCode == 'en'
                                          ? 'Filtered: ${widget.initialVaccineLabel}'
                                          : 'Filtré : ${widget.initialVaccineLabel}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            color: Colors.white38,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun reel dans cette catégorie',
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category filter bar — horizontal chips at the top
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelected});

  final ReelCategory? selected;
  final void Function(ReelCategory?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // "Tous" chip
          _CategoryChip(
            label: 'Tous',
            emoji: '✨',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...ReelCategory.values.map(
            (cat) => _CategoryChip(
              label: cat.shortLabel,
              emoji: cat.emoji,
              isSelected: selected == cat,
              onTap: () => onSelected(cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.magentaPink, AppColors.coral],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.25),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.magentaPink.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$emoji $label',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
