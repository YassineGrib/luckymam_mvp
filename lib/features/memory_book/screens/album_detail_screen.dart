import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../models/album_suggestion.dart';

/// Flagship Dual-Mode Album Detail Screen for LuckyMam.
/// Allows mothers to explore their memories in two distinct modes:
/// 1. Book Flip Mode: Realistic horizontal children's photobook reader with
///    binding spine, high-res photo frames, audio notes, and page curl feel.
/// 2. Grid Overview Mode: Responsive photo mosaic with emotion tags and stats.
class AlbumDetailScreen extends StatefulWidget {
  final AlbumSuggestion album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
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
    final album = widget.album;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final accentColor = album.accentColor;

    final audioCount = album.capsules.where((c) => c.hasAudio).length;
    final favCount = album.capsules.where((c) => c.isFavorite).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient Glow tinted with Album Accent Color
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
                      accentColor.withValues(alpha: isDark ? 0.22 : 0.16),
                      accentColor.withValues(alpha: isDark ? 0.05 : 0.03),
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
                // ── 1. Top Integrated Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
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

                      // Album Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.title,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              album.subtitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Dual Mode Switcher (Book 📖 vs Grid ▦)
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
                            _buildModeTab(
                              icon: Icons.auto_stories_rounded,
                              isSelected: _isBookMode,
                              accentColor: accentColor,
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
                              accentColor: accentColor,
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

                // ── 2. Compact Stats Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFEFE9EE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.03,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.photo_library_rounded,
                          label: isRtl ? 'الصور' : 'Photos',
                          count: '${album.count}',
                          color: accentColor,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: secondaryText.withValues(alpha: 0.2),
                        ),
                        _buildStatItem(
                          icon: Icons.mic_rounded,
                          label: isRtl ? 'صوتيات' : 'Audios',
                          count: '$audioCount',
                          color: const Color(0xFF0D9488),
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: secondaryText.withValues(alpha: 0.2),
                        ),
                        _buildStatItem(
                          icon: Icons.favorite_rounded,
                          label: isRtl ? 'المفضلة' : 'Favoris',
                          count: '$favCount',
                          color: AppColors.coral,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── 3. Content Viewport ──
                Expanded(
                  child: album.capsules.isEmpty
                      ? _buildEmptyState(context, textColor, secondaryText)
                      : _isBookMode
                          ? _buildBookFlipView(
                              context: context,
                              album: album,
                              textColor: textColor,
                              secondaryText: secondaryText,
                              accentColor: accentColor,
                              isDark: isDark,
                              isRtl: isRtl,
                            )
                          : _buildGridOverview(
                              context: context,
                              album: album,
                              textColor: textColor,
                              isDark: isDark,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required Color textColor,
    required Color secondaryText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          count,
          style: AppTypography.fromContext(
            context,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.fromContext(
            context,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 56, color: secondaryText),
            const SizedBox(height: 16),
            Text(
              'لا توجد ذكريات في هذا الألبوم بعد',
              style: AppTypography.fromContext(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أضيفي كبسولات وصور طفلكِ لملء صفحات هذا الكتاب',
              style: AppTypography.fromContext(
                context,
                fontSize: 13,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODE 1: BOOK FLIP VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBookFlipView({
    required BuildContext context,
    required AlbumSuggestion album,
    required Color textColor,
    required Color secondaryText,
    required Color accentColor,
    required bool isDark,
    required bool isRtl,
  }) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: album.capsules.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _currentPageIndex = i);
            },
            itemBuilder: (context, index) {
              final capsule = album.capsules[index];
              return _CapsulePhotobookPage(
                capsule: capsule,
                pageIndex: index,
                totalPages: album.capsules.length,
                accentColor: accentColor,
                textColor: textColor,
                secondaryText: secondaryText,
                isDark: isDark,
                isRtl: isRtl,
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Thumbnail Dots Scrubber
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(album.capsules.length, (i) {
              final isCurrent = i == _currentPageIndex;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: isCurrent ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isCurrent
                        ? accentColor
                        : isDark
                            ? Colors.white24
                            : Colors.black12,
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODE 2: GRID OVERVIEW MOSAIC
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGridOverview({
    required BuildContext context,
    required AlbumSuggestion album,
    required Color textColor,
    required bool isDark,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        8,
        AppSpacing.screenPaddingH,
        30,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: album.capsules.length,
      itemBuilder: (context, index) {
        final capsule = album.capsules[index];
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (capsule.photoUrl.isNotEmpty)
                  Image.network(
                    capsule.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                    ),
                  )
                else
                  Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Icon(Icons.photo_rounded, color: Colors.grey),
                  ),

                // Scrim
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Emotion Icon
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      capsule.emotion.icon,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Audio indicator
                if (capsule.hasAudio)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A photobook page rendering a single memory capsule in high-definition.
class _CapsulePhotobookPage extends StatelessWidget {
  const _CapsulePhotobookPage({
    required this.capsule,
    required this.pageIndex,
    required this.totalPages,
    required this.accentColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.isRtl,
  });

  final Capsule capsule;
  final int pageIndex;
  final int totalPages;
  final Color accentColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
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
            // Center Photobook Gutter Binding Shadow
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

            // Page Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page index & Emotion tag
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
                            Icon(capsule.emotion.icon, size: 14, color: accentColor),
                            const SizedBox(width: 5),
                            Text(
                              capsule.emotion.getLabel(
                                Localizations.localeOf(context).languageCode,
                              ),
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

                  const SizedBox(height: 12),

                  // Large Photobook Picture Frame
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CapsuleDetailScreen(capsule: capsule),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                capsule.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              // Bottom gradient with category / favorite
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
                                      if (capsule.isFavorite) ...[
                                        const Icon(
                                          Icons.favorite_rounded,
                                          size: 15,
                                          color: AppColors.coral,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        capsule.category?.getLabel(Localizations.localeOf(context).languageCode) ??
                                            capsule.emotion.getLabel(Localizations.localeOf(context).languageCode),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Audio Badge on Photo
                              if (capsule.hasAudio)
                                Positioned(
                                  top: 10,
                                  left: isRtl ? null : 10,
                                  right: isRtl ? 10 : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mic_rounded,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'تسجيل صوتي',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Open Capsule Detail Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CapsuleDetailScreen(capsule: capsule),
                          ),
                        );
                      },
                      icon: Icon(Icons.fullscreen_rounded, size: 18, color: accentColor),
                      label: Text(
                        'عرض تفاصيل الذكرى كاملة',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
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
    );
  }
}
