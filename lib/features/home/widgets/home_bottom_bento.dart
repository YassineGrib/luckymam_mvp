import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../marketplace/screens/marketplace_screen.dart';
import '../../memory_book/providers/memory_book_providers.dart';
import '../../memory_book/screens/memory_book_screen.dart';

/// Redesigned 2-card bottom Bento row.
/// Pairs the Partner Marketplace with the Livre de Vie (Memory Book)
/// in modern boutique squircle cards with corner-bleeding watermark icons.
class HomeBottomBento extends ConsumerWidget {
  const HomeBottomBento({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final albumCount = ref.watch(albumCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          // ─── 1. Marketplace Card ──────────────────────────────────
          Expanded(
            child: _buildBentoCard(
              context: context,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                );
              },
              lightBg: const Color(0xFFFFF7ED),
              darkBg: const Color(0xFF261D18),
              lightBorder: const Color(0xFFFFEDD5),
              accentColor: const Color(0xFFE8833A),
              watermarkIcon: Icons.storefront_rounded,
              pillIcon: Icons.storefront_rounded,
              pillLabel: l10n.marketplaceTitle,
              title: l10n.marketplaceTitle,
              subtitle: l10n.homeMarketplaceSubtitle,
            ),
          ),

          const SizedBox(width: 14),

          // ─── 2. Livre de Vie Card ────────────────────────────────
          Expanded(
            child: _buildBentoCard(
              context: context,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MemoryBookScreen()),
                );
              },
              lightBg: const Color(0xFFF0FDF4),
              darkBg: const Color(0xFF16251D),
              lightBorder: const Color(0xFFDCFCE7),
              accentColor: const Color(0xFF16A34A),
              watermarkIcon: Icons.auto_stories_rounded,
              pillIcon: Icons.auto_stories_rounded,
              pillLabel: l10n.quickActionMemories,
              title: l10n.memoryBookTitle,
              subtitle: albumCount > 0
                  ? l10n.homeMemoryBookAlbumsCount(albumCount)
                  : l10n.homeMemoryBookEmptySubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required bool isDark,
    required VoidCallback onTap,
    required Color lightBg,
    required Color darkBg,
    required Color lightBorder,
    required Color accentColor,
    required IconData watermarkIcon,
    required IconData pillIcon,
    required String pillLabel,
    required String title,
    required String subtitle,
  }) {
    final bg = isDark ? darkBg : lightBg;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 152,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : accentColor.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Bleeding Watermark Icon
              Positioned(
                bottom: -22,
                right: -18,
                child: IgnorePointer(
                  child: Icon(
                    watermarkIcon,
                    size: 88,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : accentColor.withValues(alpha: 0.09),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Micro Pill + Arrow Outward
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(pillIcon, size: 11, color: accentColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    pillLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 13,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF4A4442),
                          ),
                        ),
                      ],
                    ),

                    // Bottom: Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF221A20),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : const Color(0xFF6B6260),
                          ),
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
    );
  }
}
