import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/reel_item.dart';
import '../providers/reels_provider.dart';

/// TikTok-style overlay on top of the video with title, description, and action buttons.
class ReelOverlay extends ConsumerWidget {
  const ReelOverlay({super.key, required this.reel});

  final ReelItem reel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Bottom gradient scrim
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 260,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),

        // Right-side action buttons (TikTok-style)
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: reel.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${reel.likeCount}',
                color: reel.isFavorite ? AppColors.magentaPink : Colors.white,
                onTap: () =>
                    ref.read(reelsProvider.notifier).toggleFavorite(reel.id),
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Sauver',
                color: Colors.white,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Partager',
                color: Colors.white,
                onTap: () {},
              ),
            ],
          ),
        ),

        // Bottom info section
        Positioned(
          left: 16,
          right: 80,
          bottom: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.magentaPink,
                        width: 2,
                      ),
                      color: AppColors.magentaPink.withValues(alpha: 0.3),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    reel.author,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                reel.title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                reel.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single action button (right side column).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
