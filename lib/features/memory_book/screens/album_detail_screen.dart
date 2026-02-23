import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../models/album_suggestion.dart';

/// Detail screen showing capsules within a specific album.
class AlbumDetailScreen extends StatelessWidget {
  final AlbumSuggestion album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: album.accentColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 56,
                bottom: 16,
                right: 16,
              ),
              title: Text(
                album.title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image or gradient
                  if (album.coverUrl != null && album.coverUrl!.isNotEmpty)
                    Image.network(
                      album.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildHeroGradient(),
                    )
                  else
                    _buildHeroGradient(),

                  // Dark overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),

                  // Album info overlay
                  Positioned(
                    bottom: 56,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            album.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          album.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.screenPaddingH),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    Icons.photo_rounded,
                    '${album.count}',
                    'Photos',
                    textColor,
                    secondaryText,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: secondaryText.withValues(alpha: 0.2),
                  ),
                  _buildStat(
                    Icons.mic_rounded,
                    '${album.capsules.where((c) => c.hasAudio).length}',
                    'Audios',
                    textColor,
                    secondaryText,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: secondaryText.withValues(alpha: 0.2),
                  ),
                  _buildStat(
                    Icons.favorite_rounded,
                    '${album.capsules.where((c) => c.isFavorite).length}',
                    'Favoris',
                    textColor,
                    secondaryText,
                  ),
                ],
              ),
            ),
          ),

          // Capsules grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              0,
              AppSpacing.screenPaddingH,
              100,
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final capsule = album.capsules[index];
                return _buildCapsuleTile(context, capsule, isDark);
              }, childCount: album.count),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    IconData icon,
    String value,
    String label,
    Color textColor,
    Color secondaryText,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: album.accentColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, color: secondaryText),
        ),
      ],
    );
  }

  Widget _buildCapsuleTile(BuildContext context, Capsule capsule, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleDetailScreen(capsule: capsule),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            capsule.photoUrl.isNotEmpty
                ? Image.network(
                    capsule.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceContainerLight,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceContainerLight,
                    child: const Center(
                      child: Icon(
                        Icons.photo_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),

            // Emotion badge (bottom-right)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  capsule.emotion.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            // Audio indicator (top-left)
            if (capsule.hasAudio)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [album.accentColor, album.accentColor.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(
        child: Icon(
          album.icon,
          size: 64,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
