import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/providers/profile_providers.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../models/capsule.dart';
import '../providers/capsule_providers.dart';
import '../widgets/audio_player.dart';

/// Detail screen for viewing a single capsule.
class CapsuleDetailScreen extends ConsumerStatefulWidget {
  const CapsuleDetailScreen({super.key, required this.capsule});

  final Capsule capsule;

  @override
  ConsumerState<CapsuleDetailScreen> createState() =>
      _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends ConsumerState<CapsuleDetailScreen> {
  bool _isAudioPlaying = false;

  Capsule get capsule => widget.capsule;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(isPremiumProvider);

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
          // ── Full-screen photo (Ken Burns) ──────────────────────
          Positioned.fill(
            child: Hero(
              tag: 'capsule_${capsule.id}',
              child: _LivingCover(photoUrl: capsule.photoUrl),
            ),
          ),

          // ── All UI elements hidden when audio is playing ───────
          AnimatedOpacity(
            opacity: _isAudioPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _isAudioPlaying,
              child: Stack(
                children: [
                  // Top gradient
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
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom gradient
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 300,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xE6000000), Colors.transparent],
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
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            // Share (Premium only)
                            IconButton(
                              onPressed: () => isPremium
                                  ? _shareCapsule(context)
                                  : _showUpgradePrompt(context),
                              style: IconButton.styleFrom(
                                backgroundColor: isPremium
                                    ? Colors.black38
                                    : Colors.black26,
                              ),
                              tooltip: isPremium
                                  ? 'Partager'
                                  : 'Premium requis',
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                  ),
                                  if (!isPremium)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.goldenrod,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Save to gallery (Premium only)
                            IconButton(
                              onPressed: () => isPremium
                                  ? _saveCapsule(context)
                                  : _showUpgradePrompt(context),
                              style: IconButton.styleFrom(
                                backgroundColor: isPremium
                                    ? Colors.black38
                                    : Colors.black26,
                              ),
                              tooltip: isPremium
                                  ? 'Enregistrer'
                                  : 'Premium requis',
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                  ),
                                  if (!isPremium)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.goldenrod,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Favourite
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
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
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
                        padding: const EdgeInsets.all(
                          AppSpacing.screenPaddingH,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Emotion row
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                            // Audio player — triggers immersive mode
                            if (capsule.hasAudio) ...[
                              const SizedBox(height: AppSpacing.md),
                              CapsuleAudioPlayer(
                                audioUrl: capsule.audioUrl!,
                                duration: capsule.audioDuration ?? 0,
                                onPlayingChanged: (playing) =>
                                    setState(() => _isAudioPlaying = playing),
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
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
            ),
          ),

          // ── Tap anywhere to restore UI while audio plays ───────
          if (_isAudioPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isAudioPlaying = false),
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
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

  /// Share the capsule image + title via system share sheet.
  Future<void> _shareCapsule(BuildContext context) async {
    try {
      final snack = ScaffoldMessenger.of(context);
      snack.showSnackBar(
        const SnackBar(
          content: Text('Préparation du partage…'),
          duration: Duration(seconds: 2),
        ),
      );
      // Download image bytes
      final response = await http.get(Uri.parse(capsule.photoUrl));
      final file = XFile.fromData(
        response.bodyBytes,
        name: 'luckymam_${capsule.id}.jpg',
        mimeType: 'image/jpeg',
      );

      final text =
          '✨ Un souvenir précieux via LuckyMam\n${capsule.emotion.labelFr}';

      await SharePlus.instance.share(ShareParams(files: [file], text: text));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de partage: $e')));
      }
    }
  }

  /// Save the capsule image to the device gallery.
  Future<void> _saveCapsule(BuildContext context) async {
    try {
      // Request permission
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission galerie refusée')),
            );
          }
          return;
        }
      }
      // Download then save
      await Gal.putImageBytes(
        (await http.get(Uri.parse(capsule.photoUrl))).bodyBytes,
        album: 'LuckyMam',
        name: 'luckymam_${capsule.id}',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enregistré dans l\'album LuckyMam 📸',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur d\'enregistrement: $e')));
      }
    }
  }

  /// Show upgrade prompt for free users.
  void _showUpgradePrompt(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primaryLight.withOpacity(0.7),
                  ],
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Fonctionnalité Premium',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.onSurfaceLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le partage et l\'enregistrement de capsules\nsont réservés aux abonnés Premium et VIP.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, Color(0xFFFF8C94)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '🌟 Passer à Premium — 2 490 DA/an',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Plus tard',
                style: GoogleFonts.outfit(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
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
