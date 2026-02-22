import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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

/// Gallery screen for viewing all capsules.
class CapsulesGallery extends ConsumerWidget {
  const CapsulesGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Header with add button and quota
            _buildHeader(
              context,
              ref,
              textColor,
              secondaryText,
              primary,
              canCreate.valueOrNull ?? true,
              remaining.valueOrNull ?? freemiumCapsuleLimit,
            ),

            // Child filter pills
            childrenAsync.when(
              loading: () => const SizedBox(height: 50),
              error: (_, __) => const SizedBox.shrink(),
              data: (children) => _buildChildFilter(
                context,
                ref,
                children,
                filters.childId,
                isDark,
                primary,
                textColor,
                secondaryText,
              ),
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
                error: (error, _) =>
                    _buildErrorState(ref, textColor, secondaryText, primary),
                data: (capsules) {
                  if (capsules.isEmpty) {
                    return _buildEmptyState(primary, textColor, secondaryText);
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

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color secondaryText,
    Color primary,
    bool canCreate,
    int remaining,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        AppSpacing.md,
        AppSpacing.screenPaddingH,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes Capsules',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$remaining restantes',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: remaining > 5
                            ? secondaryText
                            : AppColors.warning,
                        fontWeight: remaining <= 5
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (remaining <= 5)
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Add button - disabled when quota exceeded
          GestureDetector(
            onTap: canCreate
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateCapsuleScreen(),
                    ),
                  )
                : () => _showQuotaExceededDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: canCreate ? AppColors.primaryGradient : null,
                color: canCreate ? null : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    canCreate ? Icons.add_rounded : Icons.lock_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Capturer',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuotaExceededDialog(BuildContext context) {
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
              'Limite atteinte',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.onSurfaceLight,
              ),
            ),
          ],
        ),
        content: Text(
          'Vous avez atteint la limite de $freemiumCapsuleLimit capsules pour le forfait gratuit. Passez à Premium pour un stockage illimité!',
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
              'Compris',
              style: GoogleFonts.outfit(
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
              'Voir Premium',
              style: GoogleFonts.outfit(
                color: AppColors.goldenrod,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildFilter(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> children,
    String? selectedChildId,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    if (children.isEmpty) return const SizedBox.shrink();

    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.xs,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          // "All" card at index 0
          if (index == 0) {
            final isSelected = selectedChildId == null;
            return GestureDetector(
              onTap: () =>
                  ref.read(capsuleFilterProvider.notifier).setChildId(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withValues(alpha: 0.15) : surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Tous',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : textColor,
                    ),
                  ),
                ),
              ),
            );
          }

          final child = children[index - 1] as Child;
          final isSelected = selectedChildId == child.id;

          return GestureDetector(
            onTap: () =>
                ref.read(capsuleFilterProvider.notifier).setChildId(child.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 130,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primary.withValues(alpha: 0.15) : surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? primary
                          : secondaryText.withValues(alpha: 0.2),
                      border: Border.all(
                        color: isSelected
                            ? primary.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child.photoUrl != null && child.photoUrl!.isNotEmpty
                        ? Image.network(
                            child.photoUrl!,
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                child.name.isNotEmpty
                                    ? child.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : secondaryText,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              child.name.isNotEmpty
                                  ? child.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : secondaryText,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      child.name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primary : textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Capsule> capsules) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
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

  Widget _buildEmptyState(Color primary, Color textColor, Color secondaryText) {
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
              'Aucune capsule',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Capturez vos premiers souvenirs\nen appuyant sur le bouton ci-dessous',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    WidgetRef ref,
    Color textColor,
    Color secondaryText,
    Color primary,
  ) {
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
              'Erreur de chargement',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Impossible de charger les capsules',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Retry button
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
                'Réessayer',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
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
