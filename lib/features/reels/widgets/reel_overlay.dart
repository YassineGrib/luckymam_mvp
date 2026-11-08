import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/reel_actions.dart';
import '../reel_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../models/reel_item.dart';
import '../providers/reels_provider.dart';

/// TikTok-style overlay on top of the video with title, description, and action buttons.
class ReelOverlay extends ConsumerStatefulWidget {
  const ReelOverlay({super.key, required this.reel});

  final ReelItem reel;

  @override
  ConsumerState<ReelOverlay> createState() => _ReelOverlayState();
}

class _ReelOverlayState extends ConsumerState<ReelOverlay> {
  bool _busy = false;
  bool _saving = false;
  ReelItem get reel => widget.reel;

  Future<void> _perform(bool save) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _saving = save;
    });
    final language = Localizations.localeOf(context).languageCode;
    try {
      final actions = ReelActions();
      if (save) {
        await actions.save(reel.assetPath);
      } else {
        await actions.share(
          reel.assetPath,
          '${reel.titleFor(language)}\n${reel.descriptionFor(language)}',
        );
      }
      if (mounted && save) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reelMessage(language, 'saved'))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reelMessage(language, 'actionError'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
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

        // Brand sits above the scrim, physically bottom-left in every locale.
        Positioned(
          left: 16,
          bottom: 196,
          child: IgnorePointer(
            child: Opacity(
              key: const ValueKey('reel-brand-opacity'),
              opacity: 0.5,
              child: SvgPicture.asset(
                'assets/logo/logo svg.svg',
                width: 76,
                height: 76,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
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
                icon: Icons.download_rounded,
                busy: _busy && _saving,
                label: l10n.reelsSave,
                color: Colors.white,
                onTap: () => _perform(true),
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.share_rounded,
                busy: _busy && !_saving,
                label: l10n.share,
                color: Colors.white,
                onTap: () => _perform(false),
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
                    style: AppTypography.fromContext(
                      context,
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
                reel.titleFor(language),
                style: AppTypography.fromContext(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                reel.descriptionFor(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.fromContext(
                  context,
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
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.fromContext(
                context,
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
