import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

import '../models/album_suggestion.dart';

/// Grid card showing an album cover with title and capsule count,
/// styled with boutique photobook details and tactile press animation.
class AlbumCoverCard extends StatefulWidget {
  final AlbumSuggestion album;
  final VoidCallback onTap;

  const AlbumCoverCard({super.key, required this.album, required this.onTap});

  @override
  State<AlbumCoverCard> createState() => _AlbumCoverCardState();
}

class _AlbumCoverCardState extends State<AlbumCoverCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: album.accentColor.withValues(
                  alpha: isDark ? 0.25 : 0.18,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover image or gradient placeholder
                if (album.coverUrl != null && album.coverUrl!.isNotEmpty)
                  Image.network(
                    album.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildGradientPlaceholder(),
                  )
                else
                  _buildGradientPlaceholder(),

                // Deep 3-stop gradient scrim overlay for crystal-clear readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Photobook spine highlight on the left edge
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.5),
                          album.accentColor.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Type badge (top-right) with frosted glass styling
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: album.accentColor.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(album.icon, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${album.count}',
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Audio indicator (top-left)
                if (album.hasAudio)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),

                // Title + subtitle (bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          album.title,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          album.subtitle,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.album.accentColor.withValues(alpha: 0.85),
            widget.album.accentColor.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.album.icon,
          size: 46,
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
