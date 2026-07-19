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
import '../providers/standard_album_providers.dart';
import '../widgets/album_cover_card.dart';
import 'album_detail_screen.dart';
import 'album_template_picker_screen.dart';
import 'standard_album_detail_screen.dart';
import '../../../shared/widgets/page_header_with_filter.dart';

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
            childrenAsync.when(
              loading: () => const SizedBox(height: 50),
              error: (_, _) => const SizedBox.shrink(),
              data: (children) => PageHeaderWithFilter(
                title: 'Livre de Mémoires',
                subtitle: 'Albums auto-générés',
                icon: Icons.auto_stories_rounded,
                iconGradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFFFAB00)],
                ),
                showBackButton: true,
                childrenList: children.cast<Child>(),
                selectedChildId: childFilter,
                allowAll: true,
                onChildSelected: (id) {
                  ref.read(memoryBookChildFilterProvider.notifier).state = id;
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Album creation entry points
            childrenAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (children) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _AlbumEntryBanner(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Album prédéfini',
                        subtitle: 'Naissance, 1ère année…',
                        gradientColors: const [
                          Color(0xFFFF6F91),
                          Color(0xFF7C4DFF),
                        ],
                        onTap: () => _openTemplatePicker(
                          context,
                          children.cast<Child>(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _AlbumEntryBanner(
                        icon: Icons.dashboard_customize_rounded,
                        title: 'Album libre',
                        subtitle: 'Pages vierges à remplir',
                        gradientColors: const [
                          Color(0xFF00BFA5),
                          Color(0xFF448AFF),
                        ],
                        onTap: () => _openStandardAlbumCreator(
                          context,
                          ref,
                          children.cast<Child>(),
                        ),
                      ),
                    ),
                  ],
                ),
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

  void _openTemplatePicker(BuildContext context, List<Child> children) {
    _resolveChild(context, children, (child) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlbumTemplatePickerScreen(
            childId: child.id,
            childName: child.name,
          ),
        ),
      );
    });
  }

  void _openStandardAlbumCreator(
    BuildContext context,
    WidgetRef ref,
    List<Child> children,
  ) {
    _resolveChild(context, children, (child) {
      _showCreateStandardAlbumDialog(context, ref, child);
    });
  }

  /// Resolves which child an album should be created for: skips the prompt
  /// if there's only one, otherwise shows a picker sheet.
  void _resolveChild(
    BuildContext context,
    List<Child> children,
    ValueChanged<Child> onResolved,
  ) {
    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d\'abord un enfant pour créer un album'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (children.length == 1) {
      onResolved(children.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Pour quel enfant ?',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...children.map(
              (child) => ListTile(
                leading: const Icon(Icons.child_care_rounded),
                title: Text(child.name),
                onTap: () {
                  Navigator.pop(ctx);
                  onResolved(child);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateStandardAlbumDialog(
    BuildContext context,
    WidgetRef ref,
    Child child,
  ) {
    final controller = TextEditingController(text: 'Album de ${child.name}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Nouvel album libre',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Titre de l\'album'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              Navigator.pop(ctx);
              if (title.isEmpty) return;

              final album = await ref
                  .read(standardAlbumActionsProvider.notifier)
                  .createAlbum(childId: child.id, title: title);

              if (!context.mounted) return;
              if (album == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la création de l\'album'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StandardAlbumDetailScreen(
                    albumId: album.id,
                    childId: child.id,
                  ),
                ),
              );
            },
            child: const Text('Créer'),
          ),
        ],
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
      itemBuilder: (_, _) {
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

/// Entry point banner leading to an album-creation flow.
class _AlbumEntryBanner extends StatelessWidget {
  const _AlbumEntryBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
