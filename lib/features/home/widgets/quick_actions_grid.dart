import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../health/screens/health_hub_screen.dart';
import '../../memory_book/screens/memory_book_screen.dart';
import '../../reels/screens/reels_screen.dart';

/// 1×4 quick action grid for common dashboard shortcuts.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _QuickActionItem(
              icon: Icons.add_a_photo_rounded,
              color: AppColors.magentaPink,
              cardColor: cardColor,
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.play_circle_fill_rounded,
              color: AppColors.smaltBlue,
              cardColor: cardColor,
              isDark: isDark,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReelsScreen())),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.monitor_heart_rounded,
              color: AppColors.success,
              cardColor: cardColor,
              isDark: isDark,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HealthHubScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.auto_stories_rounded,
              color: AppColors.casablanca,
              cardColor: cardColor,
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

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color cardColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.05 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: color, size: 32)),
        ),
      ),
    );
  }
}
