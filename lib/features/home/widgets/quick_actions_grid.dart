import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../memory_book/screens/memory_book_screen.dart';
import '../../reels/screens/reels_screen.dart';

/// Modern 1×4 quick action grid for common dashboard shortcuts with micro-labels and tactile press effects.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _QuickActionItem(
              label: l10n.quickActionCapsule,
              icon: Icons.add_a_photo_rounded,
              color: AppColors.magentaPink,
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionItem(
              label: l10n.quickActionReels,
              icon: Icons.play_circle_fill_rounded,
              color: AppColors.smaltBlue,
              isDark: isDark,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReelsScreen())),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionItem(
              label: l10n.quickActionHealth,
              icon: Icons.monitor_heart_rounded,
              color: AppColors.success,
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HealthHubScreen()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionItem(
              label: l10n.quickActionMemories,
              icon: Icons.auto_stories_rounded,
              color: AppColors.casablanca,
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemoryBookScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final badgeBg = widget.color.withValues(
      alpha: widget.isDark ? 0.22 : 0.12,
    );

    final borderColor = widget.color.withValues(
      alpha: widget.isDark ? 0.35 : 0.25,
    );

    final textColor = widget.isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft Tinted Circular Icon Badge (No white box background, no shadow glow)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Clean Micro-Label
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

