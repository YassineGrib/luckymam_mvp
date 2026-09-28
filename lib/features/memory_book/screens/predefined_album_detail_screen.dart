import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../print_album/services/album_pdf_service.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/album_templates_data.dart';
import '../models/album_template.dart';
import '../models/predefined_album.dart';
import '../providers/predefined_album_providers.dart';
import '../widgets/album_print_cta.dart';
import '../widgets/capsule_picker_sheet.dart';
import 'album_template_picker_screen.dart';

/// Redesigned flagship Predefined Album Detail Screen for LuckyMam.
/// Features a Dual-Mode Experience:
/// 1. Realistic Horizontal Book Reader (Book Flip Mode) with photobook spine,
///    page-turning physics, milestone badges, and quick memory capture.
/// 2. Grid Overview Mode for instant mosaic browsing of all slots and progress.
class PredefinedAlbumDetailScreen extends ConsumerStatefulWidget {
  const PredefinedAlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.childId,
  });

  final String albumId;
  final String childId;

  @override
  ConsumerState<PredefinedAlbumDetailScreen> createState() =>
      _PredefinedAlbumDetailScreenState();
}

class _PredefinedAlbumDetailScreenState
    extends ConsumerState<PredefinedAlbumDetailScreen> {
  bool _isBookMode = true;
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final albumAsync = ref.watch(predefinedAlbumProvider(widget.albumId));

    return Scaffold(
      backgroundColor: bgColor,
      body: albumAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral),
        ),
        error: (e, _) => Center(
          child: Text(l10n.albumErrorWithMessage(e.toString())),
        ),
        data: (album) {
          if (album == null) {
            return Center(child: Text(l10n.albumNotFound));
          }
          final template = findAlbumTemplate(album.templateId);
          if (template == null) {
            return Center(child: Text(l10n.albumTemplateNotFound));
          }

          return _buildAlbumContent(context, album, template);
        },
      ),
    );
  }

  Widget _buildAlbumContent(
    BuildContext context,
    PredefinedAlbum album,
    AlbumTemplate template,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primaryColor = template.gradientColors.first;

    final sortedSlots = [...template.slots]
      ..sort((a, b) => a.order.compareTo(b.order));
    final capsulesAsync = ref.watch(capsulesByChildProvider(album.childId));
    final childrenAsync = ref.watch(childrenProvider);
    final childName = childrenAsync
        .whenOrNull(
          data: (list) => list.where((c) => c.id == album.childId).firstOrNull,
        )
        ?.name;

    // Collect completed pages for Print CTA
    final printPages = <AlbumPdfPage>[];
    if (capsulesAsync.hasValue) {
      final capsuleList = capsulesAsync.value!;
      for (final slot in sortedSlots) {
        final capsuleId = album.slotCapsules[slot.id];
        if (capsuleId == null) continue;
        final capsule = capsuleList.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) continue;
        printPages.add(
          AlbumPdfPage(imageUrl: capsule.photoUrl, caption: slot.getTitle(lang)),
        );
      }
    }

    final filledCount = album.filledCount;
    final totalCount = template.slotCount;
    final progress = totalCount > 0 ? (filledCount / totalCount) : 0.0;

    return Stack(
      children: [
        // Top Ambient Light tinted with Album color
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 380,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
                    primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // ── 1. Luxury Interactive Top Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Frosted Squircle Back Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => AlbumTemplatePickerScreen(
                                childId: album.childId,
                                childName: childName ?? '',
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.04,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isRtl
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: textColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Album Title & Progress Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.getTitle(lang),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '$filledCount / $totalCount ${lang == 'ar' ? 'صفحات مكتملة' : (lang == 'fr' ? 'pages complétées' : 'pages completed')}',
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Mini Progress bar
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 4,
                                    backgroundColor: isDark
                                        ? Colors.white12
                                        : Colors.black.withValues(alpha: 0.06),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Dual Mode Switcher Pill (Book 📖 vs Grid ▦)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Book Mode Tab
                          _buildModeTab(
                            icon: Icons.auto_stories_rounded,
                            isSelected: _isBookMode,
                            primaryColor: primaryColor,
                            onTap: () {
                              if (!_isBookMode) {
                                HapticFeedback.selectionClick();
                                setState(() => _isBookMode = true);
                              }
                            },
                          ),
                          const SizedBox(width: 2),
                          // Grid Mode Tab
                          _buildModeTab(
                            icon: Icons.grid_view_rounded,
                            isSelected: !_isBookMode,
                            primaryColor: primaryColor,
                            onTap: () {
                              if (_isBookMode) {
                                HapticFeedback.selectionClick();
                                setState(() => _isBookMode = false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── 2. Active Mode Viewport ──
              Expanded(
                child: _isBookMode
                    ? _buildBookFlipView(
                        context: context,
                        album: album,
                        template: template,
                        sortedSlots: sortedSlots,
                        capsulesAsync: capsulesAsync,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        isDark: isDark,
                        lang: lang,
                        isRtl: isRtl,
                      )
                    : _buildGridOverview(
                        context: context,
                        album: album,
                        template: template,
                        sortedSlots: sortedSlots,
                        capsulesAsync: capsulesAsync,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        isDark: isDark,
                        lang: lang,
                      ),
              ),

              // ── 3. Bottom Print Album Luxury CTA ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingH,
                  8,
                  AppSpacing.screenPaddingH,
                  14,
                ),
                child: AlbumPrintCta(
                  childId: album.childId,
                  childName: childName ?? '',
                  albumId: album.id,
                  albumType: 'predefined',
                  albumTitle: template.getTitle(lang),
                  pages: printPages,
                  accentColor: primaryColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODE 1: REALISTIC BOOK FLIP READER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBookFlipView({
    required BuildContext context,
    required PredefinedAlbum album,
    required AlbumTemplate template,
    required List<AlbumEventSlot> sortedSlots,
    required AsyncValue<List<Capsule>> capsulesAsync,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required String lang,
    required bool isRtl,
  }) {
    return Column(
      children: [
        // Page Reader Viewport
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: sortedSlots.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _currentPageIndex = i);
            },
            itemBuilder: (context, index) {
              final slot = sortedSlots[index];
              final capsuleId = album.slotCapsules[slot.id];
              Capsule? capsule;
              if (capsuleId != null) {
                capsule = capsulesAsync.whenOrNull(
                  data: (list) =>
                      list.where((c) => c.id == capsuleId).firstOrNull,
                );
              }

              return _PhotobookPage(
                slot: slot,
                capsule: capsule,
                pageIndex: index,
                totalPages: sortedSlots.length,
                template: template,
                album: album,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryText: secondaryText,
                isDark: isDark,
                lang: lang,
                isRtl: isRtl,
                onPickExisting: () => _pickExistingCapsule(context, album, template, slot),
                onCreateNew: () => _createNewCapsule(context, album, slot),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Thumbnail Navigation Dots / Strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sortedSlots.length, (i) {
              final isCurrent = i == _currentPageIndex;
              final slot = sortedSlots[i];
              final isFilled = album.slotCapsules[slot.id] != null;

              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isCurrent ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isCurrent
                        ? primaryColor
                        : isFilled
                            ? AppColors.success.withValues(alpha: 0.6)
                            : isDark
                                ? Colors.white24
                                : Colors.black12,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODE 2: GRID OVERVIEW MOSAIC
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGridOverview({
    required BuildContext context,
    required PredefinedAlbum album,
    required AlbumTemplate template,
    required List<AlbumEventSlot> sortedSlots,
    required AsyncValue<List<Capsule>> capsulesAsync,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required String lang,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        8,
        AppSpacing.screenPaddingH,
        20,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: sortedSlots.length,
      itemBuilder: (context, index) {
        final slot = sortedSlots[index];
        final capsuleId = album.slotCapsules[slot.id];
        Capsule? capsule;
        if (capsuleId != null) {
          capsule = capsulesAsync.whenOrNull(
            data: (list) => list.where((c) => c.id == capsuleId).firstOrNull,
          );
        }

        final isFilled = capsule != null;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _currentPageIndex = index;
              _isBookMode = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(index);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1A22) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFilled
                    ? AppColors.success.withValues(alpha: 0.4)
                    : isDark
                        ? Colors.white12
                        : const Color(0xFFEBE6EA),
                width: isFilled ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isFilled)
                    Image.network(
                      capsule.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: const Icon(Icons.photo_rounded, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      color: primaryColor.withValues(alpha: 0.05),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(slot.icon, size: 22, color: primaryColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang == 'ar' ? '+ إضافة' : (lang == 'fr' ? '+ Ajouter' : '+ Add'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom Gradient Scrim for readable title
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: isFilled ? 0.85 : 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slot.getTitle(lang),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isFilled ? Colors.white : textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            lang == 'ar' ? 'صفحة ${slot.order}' : 'Page ${slot.order}',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isFilled
                                  ? Colors.white70
                                  : secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status Indicator Badge at top corner
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? AppColors.success
                            : Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFilled
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickExistingCapsule(
    BuildContext context,
    PredefinedAlbum album,
    AlbumTemplate template,
    AlbumEventSlot slot,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CapsulePickerSheet(
        childId: album.childId,
        onSelected: (capsule) {
          ref
              .read(predefinedAlbumActionsProvider.notifier)
              .attachCapsuleToSlot(
                albumId: album.id,
                slotId: slot.id,
                capsuleId: capsule.id,
                templateId: template.id,
                method: 'existing',
              );
        },
      ),
    );
  }

  void _createNewCapsule(
    BuildContext context,
    PredefinedAlbum album,
    AlbumEventSlot slot,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCapsuleScreen(
          albumId: album.id,
          albumSlotId: slot.id,
          albumType: 'predefined',
          preselectedChildId: album.childId,
        ),
      ),
    );
  }
}

/// A photobook page spread with realistic book binding aesthetics.
class _PhotobookPage extends StatelessWidget {
  const _PhotobookPage({
    required this.slot,
    required this.capsule,
    required this.pageIndex,
    required this.totalPages,
    required this.template,
    required this.album,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.lang,
    required this.isRtl,
    required this.onPickExisting,
    required this.onCreateNew,
  });

  final AlbumEventSlot slot;
  final Capsule? capsule;
  final int pageIndex;
  final int totalPages;
  final AlbumTemplate template;
  final PredefinedAlbum album;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final String lang;
  final bool isRtl;
  final VoidCallback onPickExisting;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final isFilled = capsule != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A22) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.07),
          width: 1.2,
        ),
        boxShadow: [
          // Ambient soft depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // Center Photobook Gutter Binding Shadow (left in LTR, right in RTL)
            Positioned(
              top: 0,
              bottom: 0,
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              width: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Photobook Page Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header: Slot order badge + milestone name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(slot.icon, size: 14, color: primaryColor),
                            const SizedBox(width: 5),
                            Text(
                              '${lang == 'ar' ? 'المحطة' : 'Étape'} ${slot.order}',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Page number e.g. "3 / 6"
                      Text(
                        '${pageIndex + 1} / $totalPages',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Slot Title & Description
                  Text(
                    slot.getTitle(lang),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  Text(
                    slot.getDescription(lang),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Central Photobook Spread Canvas
                  Expanded(
                    child: isFilled
                        ? _buildFilledPageCanvas(context)
                        : _buildEmptyPageCanvas(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledPageCanvas(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleDetailScreen(capsule: capsule!),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                capsule!.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                ),
              ),

              // Bottom gradient caption
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              lang == 'ar' ? 'تم الحفظ' : (lang == 'fr' ? 'Enregistré' : 'Saved'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPageCanvas(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFFBF9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 28,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang == 'ar' ? 'أضيفي صورة هذه اللحظة' : 'Ajoutez la photo de cet instant',
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'ar' ? 'لتكتمل صفحة كتاب الذكريات' : 'Pour compléter cette page',
            style: AppTypography.fromContext(
              context,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 20),

          // Two Boutique Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickExisting,
                    icon: Icon(
                      Icons.photo_library_outlined,
                      size: 15,
                      color: primaryColor,
                    ),
                    label: Text(
                      lang == 'ar'
                          ? 'من الكبسولات'
                          : (lang == 'fr' ? 'Existant' : 'From capsules'),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreateNew,
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: Text(
                      lang == 'ar'
                          ? 'التقاط الآن'
                          : (lang == 'fr' ? 'Capturer' : 'Capture now'),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
