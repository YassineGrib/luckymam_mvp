import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/album_suggestion.dart';
import '../providers/memory_book_providers.dart';
import '../widgets/album_cover_card.dart';
import 'album_detail_screen.dart';

/// Main Memory Book screen showing auto-generated album suggestions.
class MemoryBookScreen extends ConsumerWidget {
  const MemoryBookScreen({super.key});

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

    final albumsAsync = ref.watch(albumSuggestionsProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final childFilter = ref.watch(memoryBookChildFilterProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, textColor, primary),

            // Child filter pills
            childrenAsync.when(
              loading: () => const SizedBox(height: 50),
              error: (_, __) => const SizedBox.shrink(),
              data: (children) => _buildChildFilter(
                context,
                ref,
                children,
                childFilter,
                isDark,
                primary,
                textColor,
                secondaryText,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Album grid
            Expanded(
              child: albumsAsync.when(
                loading: () => _buildLoadingGrid(isDark),
                error: (e, _) => _buildErrorState(textColor, secondaryText),
                data: (albums) {
                  if (albums.isEmpty) {
                    return _buildEmptyState(primary, textColor, secondaryText);
                  }
                  return _buildAlbumGrid(context, albums);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.screenPaddingH,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF6F00), const Color(0xFFFFAB00)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livre de Mémoires',
                  style: GoogleFonts.outfit(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Albums auto-générés',
                  style: GoogleFonts.outfit(fontSize: 13, color: primary),
                ),
              ],
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
      height: 50,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.xs,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedChildId == null;
            return GestureDetector(
              onTap: () =>
                  ref.read(memoryBookChildFilterProvider.notifier).state = null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
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
                ref.read(memoryBookChildFilterProvider.notifier).state =
                    child.id,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  child.name,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? primary : textColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<AlbumSuggestion> albums) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        AppSpacing.sm,
        AppSpacing.screenPaddingH,
        100,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return AlbumCoverCard(
          album: album,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: 4,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color primary, Color textColor, Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
              child: Icon(Icons.auto_stories_rounded, size: 50, color: primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun album disponible',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Capturez plus de souvenirs\npour débloquer des albums automatiques',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color secondaryText) {
    return Center(
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
            'Impossible de générer les albums',
            style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
          ),
        ],
      ),
    );
  }
}
