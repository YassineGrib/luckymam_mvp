import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../models/standard_album.dart';
import '../providers/standard_album_providers.dart';
import '../widgets/album_print_cta.dart';
import '../widgets/capsule_picker_sheet.dart';

/// Redesigned flagship Standard (Free-form) Album Detail Screen for LuckyMam.
/// Features a Dual-Mode Experience mirroring the VIP Predefined Album:
/// 1. Realistic Horizontal Book Reader (Book Flip Mode) with photobook spine,
///    page-turning physics, audio notes display, and quick memory capture.
/// 2. Bento Grid Overview Mode for instant mosaic browsing of all pages and progress.
/// 3. Dynamic Page Management: Mother can add blank pages, reorder, rename, or print.
class StandardAlbumDetailScreen extends ConsumerStatefulWidget {
  const StandardAlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.childId,
  });

  final String albumId;
  final String childId;

  @override
  ConsumerState<StandardAlbumDetailScreen> createState() =>
      _StandardAlbumDetailScreenState();
}

class _StandardAlbumDetailScreenState
    extends ConsumerState<StandardAlbumDetailScreen> {
  bool _isBookMode = true;
  late final PageController _pageController;
  int _currentPageIndex = 0;

  static const Color _accentColor = AppColors.magentaPink;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    ref
        .read(standardAlbumActionsProvider.notifier)
        .logDraftSaved(widget.albumId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final albumAsync = ref.watch(standardAlbumProvider(widget.albumId));

    return Scaffold(
      backgroundColor: bgColor,
      body: albumAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accentColor),
        ),
        error: (e, _) => Center(
          child: Text(l10n.albumErrorWithMessage(e.toString())),
        ),
        data: (album) {
          if (album == null) {
            return Center(child: Text(l10n.albumNotFound));
          }
          return _buildAlbumContent(context, album);
        },
      ),
    );
  }

  Widget _buildAlbumContent(BuildContext context, StandardAlbum album) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

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
      for (var i = 0; i < album.pageCount; i++) {
        final capsuleId = album.pageCapsules['$i'];
        if (capsuleId == null) continue;
        final capsule = capsuleList.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) continue;
        printPages.add(
          AlbumPdfPage(
            imageUrl: capsule.photoUrl,
            caption: l10n.albumPageCaption(i + 1),
          ),
        );
      }
    }

    final filledCount = album.filledCount;
    final totalCount = album.pageCount;
    final progress = totalCount > 0 ? (filledCount / totalCount) : 0.0;

    return Stack(
      children: [
        // Top Ambient Light tinted with signature Album Magenta/Rose
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
                    _accentColor.withValues(alpha: isDark ? 0.22 : 0.16),
                    _accentColor.withValues(alpha: isDark ? 0.05 : 0.03),
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
                        Navigator.pop(context);
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
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE8E0E4),
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

                    // Album Title (tap to rename) & Progress Bar
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _renameAlbumDialog(context, album),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    album.title,
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: _accentColor.withValues(alpha: 0.8),
                                ),
                              ],
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
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor: isDark
                                          ? Colors.white12
                                          : Colors.black.withValues(alpha: 0.06),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        _accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dual Mode Switcher Pill (Book 📖 vs Grid ▦)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFE8E0E4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeTab(
                            icon: Icons.auto_stories_rounded,
                            isSelected: _isBookMode,
                            onTap: () {
                              if (!_isBookMode) {
                                HapticFeedback.selectionClick();
                                setState(() => _isBookMode = true);
                              }
                            },
                          ),
                          const SizedBox(width: 2),
                          _buildModeTab(
                            icon: Icons.grid_view_rounded,
                            isSelected: !_isBookMode,
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

                    // More Options Popup Menu (3 dots)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: secondaryText),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: isDark ? const Color(0xFF26212E) : Colors.white,
                      onSelected: (value) {
                        if (value == 'rename') {
                          _renameAlbumDialog(context, album);
                        } else if (value == 'add_page') {
                          _addNewPage(album);
                        } else if (value == 'delete') {
                          _confirmDeleteAlbum(context, album);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 18),
                              const SizedBox(width: 10),
                              Text(l10n.albumRenameTitle),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'add_page',
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_outline_rounded,
                                  size: 18, color: _accentColor),
                              const SizedBox(width: 10),
                              Text(lang == 'ar'
                                  ? 'إضافة صفحة للألبوم'
                                  : (lang == 'fr'
                                      ? 'Ajouter une page'
                                      : 'Add page')),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 10),
                              Text(
                                lang == 'ar'
                                    ? 'حذف الألبوم'
                                    : (lang == 'fr'
                                        ? 'Supprimer l\'album'
                                        : 'Delete album'),
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        capsulesAsync: capsulesAsync,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        isDark: isDark,
                        lang: lang,
                        isRtl: isRtl,
                      )
                    : _buildGridOverview(
                        context: context,
                        album: album,
                        capsulesAsync: capsulesAsync,
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
                  albumType: 'standard',
                  albumTitle: album.title,
                  pages: printPages,
                  accentColor: _accentColor,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.35),
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
  // MODE 1: REALISTIC PHOTOBOOK FLIP READER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBookFlipView({
    required BuildContext context,
    required StandardAlbum album,
    required AsyncValue<List<Capsule>> capsulesAsync,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required String lang,
    required bool isRtl,
  }) {
    // Total items in pageview = pages + 1 (the final "+ Add page" spread)
    final totalItemCount = album.pageCount + 1;

    return Column(
      children: [
        // Page Reader Viewport
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: totalItemCount,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _currentPageIndex = i);
            },
            itemBuilder: (context, index) {
              if (index == album.pageCount) {
                // The Last "+ Add New Blank Page" Card
                return _buildAddPageSpread(
                  context: context,
                  album: album,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryText: secondaryText,
                  lang: lang,
                  isRtl: isRtl,
                );
              }

              final capsuleId = album.pageCapsules['$index'];
              Capsule? capsule;
              if (capsuleId != null) {
                capsule = capsulesAsync.whenOrNull(
                  data: (list) =>
                      list.where((c) => c.id == capsuleId).firstOrNull,
                );
              }

              return _StandardPhotobookPage(
                pageIndex: index,
                totalPages: album.pageCount,
                capsule: capsule,
                album: album,
                accentColor: _accentColor,
                textColor: textColor,
                secondaryText: secondaryText,
                isDark: isDark,
                lang: lang,
                isRtl: isRtl,
                onPickExisting: () => _pickExistingCapsule(context, album, index),
                onCreateNew: () => _createNewCapsule(context, album, index),
                onClearPage: () => _clearPage(context, album, index),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Thumbnail Navigation Dots / Indicator Strip
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalItemCount, (i) {
                final isCurrent = i == _currentPageIndex;
                final isAddPage = i == album.pageCount;
                final isFilled =
                    !isAddPage && album.pageCapsules['$i'] != null;

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
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isCurrent ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isCurrent
                          ? _accentColor
                          : isFilled
                              ? AppColors.success.withValues(alpha: 0.7)
                              : isAddPage
                                  ? _accentColor.withValues(alpha: 0.4)
                                  : isDark
                                      ? Colors.white24
                                      : Colors.black12,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPageSpread({
    required BuildContext context,
    required StandardAlbum album,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    required String lang,
    required bool isRtl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A22) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
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
            // Gutter Binding Shadow
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

            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 38,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      lang == 'ar'
                          ? 'إضافة صفحة جديدة للألبوم'
                          : (lang == 'fr'
                              ? 'Ajouter une nouvelle page'
                              : 'Add new album page'),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'ar'
                          ? 'يمكنك توسيع ألبومك وحفظ المزيد من الذكريات في أي وقت'
                          : (lang == 'fr'
                              ? 'Agrandissez votre album et gardez plus de souvenirs'
                              : 'Expand your album and preserve more milestones'),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _addNewPage(album),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.add_photo_alternate_rounded,
                          size: 18),
                      label: Text(
                        lang == 'ar'
                            ? 'إضافة صفحة الآن (صفحة ${album.pageCount + 1})'
                            : (lang == 'fr'
                                ? 'Ajouter la page ${album.pageCount + 1}'
                                : 'Add Page ${album.pageCount + 1}'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODE 2: BENTO MOSAIC GRID OVERVIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGridOverview({
    required BuildContext context,
    required StandardAlbum album,
    required AsyncValue<List<Capsule>> capsulesAsync,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required String lang,
  }) {
    final totalCards = album.pageCount + 1; // pages + add page card

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        8,
        AppSpacing.screenPaddingH,
        24,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: totalCards,
      itemBuilder: (context, index) {
        if (index == album.pageCount) {
          // Add Page Tile in Grid
          return GestureDetector(
            onTap: () => _addNewPage(album),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1A22) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.4),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 26,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang == 'ar'
                          ? '+ صفحة جديدة'
                          : (lang == 'fr' ? '+ Nouvelle page' : '+ New Page'),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final capsuleId = album.pageCapsules['$index'];
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
                        child: const Icon(Icons.photo_rounded,
                            color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      color: _accentColor.withValues(alpha: 0.05),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _accentColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 22,
                                color: _accentColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang == 'ar'
                                  ? '+ إضافة'
                                  : (lang == 'fr' ? '+ Ajouter' : '+ Add'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom Gradient Scrim
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
                            Colors.black
                                .withValues(alpha: isFilled ? 0.85 : 0.08),
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
                            lang == 'ar'
                                ? 'الصفحة ${index + 1}'
                                : 'Page ${index + 1}',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isFilled ? Colors.white : textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isFilled && capsule.audioUrl != null)
                            Row(
                              children: [
                                const Icon(Icons.graphic_eq_rounded,
                                    size: 11, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  lang == 'ar' ? 'صوت مسجل' : 'Audio',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
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
                            : Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFilled ? Icons.check_rounded : Icons.add_rounded,
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

  // ───────────────────────────────────────────────────────────────────────────
  // ACTIONS & DIALOGS
  // ───────────────────────────────────────────────────────────────────────────
  void _addNewPage(StandardAlbum album) {
    HapticFeedback.mediumImpact();
    ref.read(standardAlbumActionsProvider.notifier).addPage(album.id);
    // Smoothly jump to the new page
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          album.pageCount,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _pickExistingCapsule(
    BuildContext context,
    StandardAlbum album,
    int pageIndex,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CapsulePickerSheet(
        childId: album.childId,
        onSelected: (capsule) {
          ref
              .read(standardAlbumActionsProvider.notifier)
              .addCapsuleToPage(
                albumId: album.id,
                pageIndex: pageIndex,
                capsuleId: capsule.id,
                method: 'existing',
              );
        },
      ),
    );
  }

  void _createNewCapsule(
    BuildContext context,
    StandardAlbum album,
    int pageIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCapsuleScreen(
          albumId: album.id,
          albumSlotId: '$pageIndex',
          albumType: 'standard',
          preselectedChildId: album.childId,
        ),
      ),
    );
  }

  void _clearPage(
    BuildContext context,
    StandardAlbum album,
    int pageIndex,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'ar' ? 'إفراغ الصفحة' : 'Clear Page'),
        content: Text(
          lang == 'ar'
              ? 'هل أنتِ متأكدة من إزالة هذه الصورة من الصفحة؟ لن يتم حذف الكبسولة الأصلية.'
              : 'Are you sure you want to remove this memory from the page? The original capsule will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.albumCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref
                  .read(standardAlbumActionsProvider.notifier)
                  .clearPage(albumId: album.id, pageIndex: pageIndex);
              Navigator.pop(ctx);
            },
            child: Text(lang == 'ar' ? 'إزالة' : 'Remove'),
          ),
        ],
      ),
    );
  }

  void _renameAlbumDialog(BuildContext context, StandardAlbum album) {
    final l10n = context.l10n;
    final controller = TextEditingController(text: album.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.albumRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.albumTitleHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.albumCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _accentColor),
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(standardAlbumActionsProvider.notifier)
                    .updateTitle(albumId: album.id, title: title);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.albumSave),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlbum(BuildContext context, StandardAlbum album) {
    final lang = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'ar' ? 'حذف الألبوم' : 'Delete Album'),
        content: Text(
          lang == 'ar'
              ? 'هل أنتِ متأكدة من حذف ألبوم "${album.title}" بالكامل؟'
              : 'Are you sure you want to permanently delete "${album.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.albumCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(standardAlbumActionsProvider.notifier)
                  .deleteAlbum(album.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(lang == 'ar' ? 'حذف نهائي' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

/// A luxury photobook page spread for Standard Album with photobook spine aesthetics.
class _StandardPhotobookPage extends StatelessWidget {
  const _StandardPhotobookPage({
    required this.pageIndex,
    required this.totalPages,
    required this.capsule,
    required this.album,
    required this.accentColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.lang,
    required this.isRtl,
    required this.onPickExisting,
    required this.onCreateNew,
    required this.onClearPage,
  });

  final int pageIndex;
  final int totalPages;
  final Capsule? capsule;
  final StandardAlbum album;
  final Color accentColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final String lang;
  final bool isRtl;
  final VoidCallback onPickExisting;
  final VoidCallback onCreateNew;
  final VoidCallback onClearPage;

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
                  // Page Header: Page number badge + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 14,
                              color: accentColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              lang == 'ar'
                                  ? 'الصفحة ${pageIndex + 1}'
                                  : 'Page ${pageIndex + 1}',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

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

                  const SizedBox(height: 10),

                  // Central Photobook Spread Canvas
                  Expanded(
                    child: isFilled
                        ? _buildFilledPageCanvas(context)
                        : _buildEmptyPageCanvas(context),
                  ),

                  // Bottom Action Toolbar if filled
                  if (isFilled) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onPickExisting,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentColor,
                              side: BorderSide(
                                color: accentColor.withValues(alpha: 0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                            ),
                            icon: const Icon(Icons.sync_rounded, size: 15),
                            label: Text(
                              lang == 'ar'
                                  ? 'تغيير'
                                  : (lang == 'fr' ? 'Changer' : 'Change'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onClearPage,
                          tooltip: lang == 'ar' ? 'إفراغ الصفحة' : 'Clear',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.error.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  child: const Icon(Icons.broken_image_rounded,
                      size: 40, color: Colors.grey),
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
                        Colors.black.withValues(alpha: 0.82),
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
                            const Icon(Icons.check_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              lang == 'ar'
                                  ? 'تم الحفظ'
                                  : (lang == 'fr' ? 'Enregistré' : 'Saved'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (capsule!.audioUrl != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_rounded,
                                  size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                '🎙️',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
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

              // Capture Date Chip top left
              PositionedDirectional(
                top: 10,
                start: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(
                      capsule!.capturedAt ?? capsule!.createdAt,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
          color: accentColor.withValues(alpha: 0.25),
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
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 28,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang == 'ar'
                ? 'أضيفي صورة لهذه الصفحة'
                : (lang == 'fr'
                    ? 'Ajoutez une photo pour cette page'
                    : 'Add a photo for this page'),
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'ar'
                ? 'لتكتمل صفحة كتاب الذكريات'
                : (lang == 'fr'
                    ? 'Pour compléter cette page'
                    : 'To complete this memory page'),
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
                      color: accentColor,
                    ),
                    label: Text(
                      context.l10n.albumExistingCapsule,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: accentColor.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreateNew,
                    icon: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: Text(
                      context.l10n.albumNewCapsule,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
