import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/capsule.dart';
import '../providers/capsule_providers.dart';
import '../widgets/capsule_grid_item.dart';
import '../widgets/emotion_picker.dart';
import 'capsule_detail_screen.dart';
import 'create_capsule_screen.dart';
import '../../../shared/widgets/page_header_with_filter.dart';

/// Gallery screen for viewing all capsules.
class CapsulesGallery extends ConsumerWidget {
  const CapsulesGallery({super.key});

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

    final capsulesAsync = ref.watch(filteredCapsulesProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final filters = ref.watch(capsuleFilterProvider);
    final canCreate = ref.watch(canCreateCapsuleProvider);
    final remaining = ref.watch(remainingCapsuleQuotaProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header and Child filter using shared component
            childrenAsync.when(
              loading: () => const SizedBox(height: 50),
              error: (_, _) => const SizedBox.shrink(),
              data: (children) {
                final rem = remaining.valueOrNull ?? freemiumCapsuleLimit;
                final canMake = canCreate.valueOrNull ?? true;

                return PageHeaderWithFilter(
                  title: l10n.capsulesGalleryTitle,
                  subtitleWidget: Row(
                    children: [
                      Text(
                        l10n.capsulesRemaining(rem),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: rem > 5 ? secondaryText : AppColors.warning,
                          fontWeight: rem <= 5
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (rem <= 5)
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                    ],
                  ),
                  icon: Icons.photo_camera_rounded,
                  childrenList: children.cast<Child>(),
                  selectedChildId: filters.childId,
                  allowAll: true,
                  onChildSelected: (id) =>
                      ref.read(capsuleFilterProvider.notifier).setChildId(id),
                  trailing: GestureDetector(
                    onTap: canMake
                        ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateCapsuleScreen(),
                            ),
                          )
                        : () => _showQuotaExceededDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: canMake ? AppColors.primaryGradient : null,
                        color: canMake ? null : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            canMake ? Icons.add_rounded : Icons.lock_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.milestone_capture,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Emotion filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
                vertical: AppSpacing.sm,
              ),
              child: EmotionFilterChips(
                selectedEmotion: filters.emotion,
                onEmotionSelected: (emotion) {
                  ref.read(capsuleFilterProvider.notifier).setEmotion(emotion);
                },
              ),
            ),

            // Capsules grid
            Expanded(
              child: capsulesAsync.when(
                loading: () => _buildLoadingGrid(isDark),
                error: (error, _) => _buildErrorState(
                  context,
                  ref,
                  textColor,
                  secondaryText,
                  primary,
                ),
                data: (capsules) {
                  if (capsules.isEmpty) {
                    return _buildEmptyState(context, textColor, secondaryText);
                  }
                  return _buildGrid(context, capsules);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuotaExceededDialog(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              l10n.capsulesQuotaLimitTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.onSurfaceLight,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.capsulesQuotaLimitMessage(freemiumCapsuleLimit),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.capsulesUnderstood,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to premium upgrade screen
            },
            child: Text(
              l10n.capsulesViewPremium,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.goldenrod,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Capsule> capsules) {
    return GridView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screenPaddingH,
        AppSpacing.sm,
        AppSpacing.screenPaddingH,
        100, // FAB space
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: capsules.length,
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        return CapsuleGridItem(
          capsule: capsule,
          onTap: () => _openDetail(context, capsule),
        );
      },
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    final primary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_camera_rounded, size: 50, color: primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.capsulesEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.capsulesEmptySubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.myOrdersLoadError,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.capsulesLoadErrorSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(filteredCapsulesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10n.retry,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Capsule capsule) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CapsuleDetailScreen(capsule: capsule),
      ),
    );
  }
}
