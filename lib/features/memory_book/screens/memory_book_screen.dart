import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/memory_book_providers.dart';
import '../providers/standard_album_providers.dart';
import '../widgets/album_cover_card.dart';
import 'album_detail_screen.dart';
import 'album_template_picker_screen.dart';
import 'standard_album_detail_screen.dart';
import '../../../shared/widgets/page_header_with_filter.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';

/// Main Memory Book screen showing auto-generated album suggestions.
class MemoryBookScreen extends ConsumerWidget {
  const MemoryBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final albumsAsync = ref.watch(albumSuggestionsProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final childFilter = ref.watch(memoryBookChildFilterProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header with Child Filter
                SliverToBoxAdapter(
                  child: childrenAsync.when(
                    loading: () => const SizedBox(height: 50),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (children) => PageHeaderWithFilter(
                      title: l10n.memoryBookTitle,
                      subtitle: l10n.memoryBookSubtitle,
                      icon: Icons.auto_stories_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFFFAB00)],
                      ),
                      showBackButton: true,
                      childrenList: children.cast<Child>(),
                      selectedChildId: childFilter,
                      allowAll: true,
                      onChildSelected: (id) {
                        ref.read(memoryBookChildFilterProvider.notifier).state = id;
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 2. Bento Album Creation Cards (Home-Bento Signature Style)
                SliverToBoxAdapter(
                  child: childrenAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (children) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingH,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AlbumCreationBentoCard(
                              title: l10n.albumPredefinedTitle,
                              subtitle: l10n.albumPredefinedSubtitle,
                              icon: Icons.auto_awesome_rounded,
                              watermarkIcon: Icons.auto_awesome_rounded,
                              lightBg: const Color(0xFFFFF0F5),
                              darkBg: const Color(0xFF281C28),
                              lightBorder: const Color(0xFFFFD4E2),
                              accentColor: const Color(0xFFE11D48),
                              onTap: () => _openTemplatePicker(
                                context,
                                children.cast<Child>(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _AlbumCreationBentoCard(
                              title: l10n.albumFreeTitle,
                              subtitle: l10n.albumFreeSubtitle,
                              icon: Icons.dashboard_customize_rounded,
                              watermarkIcon: Icons.dashboard_customize_rounded,
                              lightBg: const Color(0xFFF0FDF4),
                              darkBg: const Color(0xFF16251E),
                              lightBorder: const Color(0xFFDCFCE7),
                              accentColor: const Color(0xFF16A34A),
                              onTap: () => _openStandardAlbumCreator(
                                context,
                                ref,
                                children.cast<Child>(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // 3. Section Title Bar (Bridging the gap and providing count pill)
                albumsAsync.maybeWhen(
                  data: (albums) {
                    if (albums.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingH,
                        ),
                        child: Row(
                          children: [
                            Text(
                              l10n.memoryBookTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(
                                  alpha: isDark ? 0.20 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: primary.withValues(
                                    alpha: isDark ? 0.35 : 0.20,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '${albums.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 4. Albums Grid / Loading / Error / Empty States
                ...albumsAsync.when(
                  loading: () => [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingH,
                      ),
                      sliver: _buildLoadingSliverGrid(isDark),
                    ),
                  ],
                  error: (e, _) => [
                    SliverToBoxAdapter(
                      child: _buildErrorState(context, textColor, secondaryText),
                    ),
                  ],
                  data: (albums) {
                    if (albums.isEmpty) {
                      return [
                        SliverToBoxAdapter(
                          child: _buildEmptyState(
                            context,
                            primary,
                            textColor,
                            secondaryText,
                          ),
                        ),
                      ];
                    }
                    return [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingH,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final album = albums[index];
                              return AlbumCoverCard(
                                album: album,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AlbumDetailScreen(album: album),
                                  ),
                                ),
                              );
                            },
                            childCount: albums.length,
                          ),
                        ),
                      ),
                    ];
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openTemplatePicker(BuildContext context, List<Child> children) {
    _resolveChild(context, children, (child) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlbumTemplatePickerScreen(
            childId: child.id,
            childName: child.name,
          ),
        ),
      );
    });
  }

  void _openStandardAlbumCreator(
    BuildContext context,
    WidgetRef ref,
    List<Child> children,
  ) {
    _resolveChild(context, children, (child) {
      _showCreateStandardAlbumDialog(context, ref, child);
    });
  }

  /// Resolves which child an album should be created for: skips the prompt
  /// if there's only one, otherwise shows a picker sheet.
  void _resolveChild(
    BuildContext context,
    List<Child> children,
    ValueChanged<Child> onResolved,
  ) {
    final l10n = context.l10n;
    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.albumAddChildFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (children.length == 1) {
      onResolved(children.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.albumForWhichChild,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...children.map(
              (child) => ListTile(
                leading: const Icon(Icons.child_care_rounded),
                title: Text(child.name),
                onTap: () {
                  Navigator.pop(ctx);
                  onResolved(child);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateStandardAlbumDialog(
    BuildContext context,
    WidgetRef ref,
    Child child,
  ) {
    final l10n = context.l10n;
    final defaultTitle = l10n.albumDefaultTitleForChild(child.name);
    final controller = TextEditingController(text: defaultTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.albumNewFreeTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
            onPressed: () async {
              final title = controller.text.trim();
              Navigator.pop(ctx);
              if (title.isEmpty) return;

              final album = await ref
                  .read(standardAlbumActionsProvider.notifier)
                  .createAlbum(childId: child.id, title: title);

              if (!context.mounted) return;
              if (album == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.albumCreateError),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StandardAlbumDetailScreen(
                    albumId: album.id,
                    childId: child.id,
                  ),
                ),
              );
            },
            child: Text(l10n.albumCreate),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSliverGrid(bool isDark) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, _) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[750]! : Colors.grey[50]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        childCount: 4,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF221C2B)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : primary.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 38,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.memoryBookNoAlbums,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.memoryBookCaptureMore,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryText,
                    height: 1.35,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.albumLoadingError,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.memoryBookGenerateError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bento-styled album creation card matching the signature Accueil design.
class _AlbumCreationBentoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData watermarkIcon;
  final Color lightBg;
  final Color darkBg;
  final Color lightBorder;
  final Color accentColor;
  final VoidCallback onTap;

  const _AlbumCreationBentoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.watermarkIcon,
    required this.lightBg,
    required this.darkBg,
    required this.lightBorder,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_AlbumCreationBentoCard> createState() =>
      _AlbumCreationBentoCardState();
}

class _AlbumCreationBentoCardState extends State<_AlbumCreationBentoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? widget.darkBg : widget.lightBg;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : widget.lightBorder;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1B24);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.70)
        : const Color(0xFF5E5668);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 124,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(
                  alpha: isDark ? 0.16 : 0.14,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Floating corner watermark icon (matching Home Bento signature)
                PositionedDirectional(
                  bottom: -18,
                  end: -14,
                  child: IgnorePointer(
                    child: Icon(
                      widget.watermarkIcon,
                      size: 82,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : widget.accentColor.withValues(alpha: 0.10),
                    ),
                  ),
                ),

                // Foreground Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Squircle icon badge + subtle arrow outward
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? widget.accentColor.withValues(alpha: 0.20)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.accentColor.withValues(
                                  alpha: isDark ? 0.35 : 0.25,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                widget.icon,
                                color: widget.accentColor,
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white.withValues(alpha: 0.70),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: widget.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Text Block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.2,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
