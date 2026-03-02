import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/capsule.dart';
import '../providers/capsule_providers.dart';
import '../widgets/audio_player.dart';

/// Detail screen for viewing a single capsule.
class CapsuleDetailScreen extends ConsumerWidget {
  const CapsuleDetailScreen({super.key, required this.capsule});

  final Capsule capsule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final childrenAsync = ref.watch(childrenProvider);
    final childName = childrenAsync.whenOrNull(
      data: (children) {
        final child = children
            .where((c) => c.id == capsule.childId)
            .firstOrNull;
        return child?.name;
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen photo with living animation
          Positioned.fill(
            child: Hero(
              tag: 'capsule_${capsule.id}',
              child: _LivingCover(photoUrl: capsule.photoUrl),
            ),
          ),

          // Gradient overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── LuckyMam watermark (bas droite) ───────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: Opacity(
              opacity: 0.30,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.20),
                ),
                child: SvgPicture.asset(
                  'assets/logo/logo svg.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
                Row(
                  children: [
                    // Favorite button
                    IconButton(
                      onPressed: () => _toggleFavorite(context, ref),
                      style: IconButton.styleFrom(
                        backgroundColor: capsule.isFavorite
                            ? AppColors.goldenrod
                            : Colors.black38,
                      ),
                      icon: Icon(
                        capsule.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.white,
                      ),
                    ),
                    // Menu
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(context, ref, value),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Supprimer',
                                style: GoogleFonts.outfit(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emotion and title
                    Row(
                      children: [
                        Icon(
                          capsule.emotion.icon,
                          size: 32,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                capsule.emotion.labelFr,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _formatDetails(childName),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Category & date badges
                    if (capsule.category != null ||
                        capsule.capturedAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (capsule.category != null)
                            _InfoBadge(
                              label:
                                  '${capsule.category!.emoji} ${capsule.category!.labelFr}',
                            ),
                          if (capsule.capturedAt != null)
                            _InfoBadge(
                              label:
                                  '📅 ${DateFormat('d MMM yyyy', 'fr_FR').format(capsule.capturedAt!)}',
                            ),
                        ],
                      ),
                    ],

                    // Audio player
                    if (capsule.hasAudio) ...[
                      const SizedBox(height: AppSpacing.md),
                      CapsuleAudioPlayer(
                        audioUrl: capsule.audioUrl!,
                        duration: capsule.audioDuration ?? 0,
                      ),
                    ],

                    // Tags
                    if (capsule.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: capsule.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetails(String? childName) {
    final dateStr = DateFormat('d MMM yyyy', 'fr_FR').format(capsule.createdAt);
    if (childName != null) {
      return '$dateStr • $childName';
    }
    return dateStr;
  }

  void _toggleFavorite(BuildContext context, WidgetRef ref) {
    ref.read(capsuleActionsProvider.notifier).toggleFavorite(capsule.id);
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'delete') {
      _showDeleteConfirmation(context, ref);
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer la capsule ?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.onSurfaceLight,
          ),
        ),
        content: Text(
          'Cette action est irréversible. Le souvenir sera supprimé définitivement.',
          style: GoogleFonts.outfit(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref
                  .read(capsuleActionsProvider.notifier)
                  .deleteCapsule(capsule);
              if (context.mounted) {
                Navigator.pop(context); // Close detail screen
              }
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.outfit(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated cover image with slow Ken Burns effect.
class _LivingCover extends StatefulWidget {
  const _LivingCover({required this.photoUrl});

  final String photoUrl;

  @override
  State<_LivingCover> createState() => _LivingCoverState();
}

class _LivingCoverState extends State<_LivingCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Alignment> _alignAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _alignAnimation = AlignmentTween(
      begin: const Alignment(-0.05, -0.05),
      end: const Alignment(0.05, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: _alignAnimation.value,
          child: child,
        );
      },
      child: CachedNetworkImage(
        imageUrl: widget.photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(color: Colors.black),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white54,
            size: 60,
          ),
        ),
      ),
    );
  }
}

/// Small translucent badge used in the detail overlay.
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
