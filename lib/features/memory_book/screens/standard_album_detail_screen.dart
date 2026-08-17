import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../print_album/services/album_pdf_service.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/standard_album.dart';
import '../providers/standard_album_providers.dart';
import '../widgets/album_print_cta.dart';
import '../widgets/capsule_picker_sheet.dart';

/// Free-form album: a growable grid of blank pages the mother fills at her
/// own pace, with an existing capsule or a newly captured one. State is
/// persisted to Firestore on every change, so leaving mid-way keeps the
/// draft intact.
class StandardAlbumDetailScreen extends ConsumerStatefulWidget {
  const StandardAlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.childId,
  });

  final String albumId;
  final String childId;

  @override
  ConsumerState<StandardAlbumDetailScreen> createState() =>
      _StandardAlbumDetailScreenState();
}

class _StandardAlbumDetailScreenState
    extends ConsumerState<StandardAlbumDetailScreen> {
  @override
  void dispose() {
    // Every write already lands in Firestore immediately — this simply logs
    // the checkpoint that the draft state was preserved on exit.
    ref
        .read(standardAlbumActionsProvider.notifier)
        .logDraftSaved(widget.albumId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final albumAsync = ref.watch(standardAlbumProvider(widget.albumId));

    return Scaffold(
      backgroundColor: bgColor,
      body: albumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l10n.albumErrorWithMessage(e.toString())),
        ),
        data: (album) {
          if (album == null) {
            return Center(
              child: Text(l10n.albumNotFound),
            );
          }
          return _StandardAlbumBody(
            album: album,
            textColor: textColor,
            secondaryText: secondaryText,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _StandardAlbumBody extends ConsumerWidget {
  const _StandardAlbumBody({
    required this.album,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
  });

  final StandardAlbum album;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;

  static const _accent = AppColors.magentaPink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final capsulesAsync = ref.watch(capsulesByChildProvider(album.childId));
    final childrenAsync = ref.watch(childrenProvider);
    final childName = childrenAsync
        .whenOrNull(
          data: (list) => list.where((c) => c.id == album.childId).firstOrNull,
        )
        ?.name;

    final printPages = <AlbumPdfPage>[];
    if (capsulesAsync.hasValue) {
      final capsuleList = capsulesAsync.value!;
      for (var i = 0; i < album.pageCount; i++) {
        final capsuleId = album.pageCapsules['$i'];
        if (capsuleId == null) continue;
        final capsule = capsuleList.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) continue;
        printPages.add(
          AlbumPdfPage(
            imageUrl: capsule.photoUrl,
            caption: l10n.albumPageCaption(i + 1),
          ),
        );
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          foregroundColor: textColor,
          title: GestureDetector(
            onTap: () => _renameAlbum(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    album.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.edit_rounded, size: 14, color: secondaryText),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.sm,
            AppSpacing.screenPaddingH,
            8,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.albumPagesFilledDraft(album.filledCount, album.pageCount),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: secondaryText,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.sm,
            AppSpacing.screenPaddingH,
            32,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == album.pageCount) {
                return _AddPageTile(albumId: album.id, isDark: isDark);
              }
              final capsuleId = album.pageCapsules['$index'];
              Capsule? capsule;
              if (capsuleId != null) {
                capsule = capsulesAsync.whenOrNull(
                  data: (list) =>
                      list.where((c) => c.id == capsuleId).firstOrNull,
                );
              }
              return capsule != null
                  ? _FilledPageTile(capsule: capsule, isDark: isDark)
                  : _EmptyPageTile(
                      album: album,
                      pageIndex: index,
                      isDark: isDark,
                      accent: _accent,
                    );
            }, childCount: album.pageCount + 1),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            0,
            AppSpacing.screenPaddingH,
            32,
          ),
          sliver: SliverToBoxAdapter(
            child: AlbumPrintCta(
              childId: album.childId,
              childName: childName ?? '',
              albumId: album.id,
              albumType: 'standard',
              albumTitle: album.title,
              pages: printPages,
              accentColor: _accent,
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }

  void _renameAlbum(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = TextEditingController(text: album.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.albumRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.albumTitleHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.albumCancel),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(standardAlbumActionsProvider.notifier)
                    .updateTitle(albumId: album.id, title: title);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.albumSave),
          ),
        ],
      ),
    );
  }
}

class _FilledPageTile extends StatelessWidget {
  const _FilledPageTile({required this.capsule, required this.isDark});

  final Capsule capsule;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CapsuleDetailScreen(capsule: capsule)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          capsule.photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _EmptyPageTile extends ConsumerWidget {
  const _EmptyPageTile({
    required this.album,
    required this.pageIndex,
    required this.isDark,
    required this.accent,
  });

  final StandardAlbum album;
  final int pageIndex;
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddOptions(context, ref),
      child: DottedBorderBox(
        isDark: isDark,
        accent: accent,
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: accent.withValues(alpha: 0.7),
          size: 26,
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: accent),
                title: Text(l10n.albumChooseExistingCapsule),
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CapsulePickerSheet(
                      childId: album.childId,
                      onSelected: (capsule) {
                        ref
                            .read(standardAlbumActionsProvider.notifier)
                            .addCapsuleToPage(
                              albumId: album.id,
                              pageIndex: pageIndex,
                              capsuleId: capsule.id,
                              method: 'existing',
                            );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add_a_photo_rounded, color: accent),
                title: Text(l10n.albumCreateNewCapsule),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateCapsuleScreen(
                        albumId: album.id,
                        albumSlotId: '$pageIndex',
                        albumType: 'standard',
                        preselectedChildId: album.childId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPageTile extends ConsumerWidget {
  const _AddPageTile({required this.albumId, required this.isDark});

  final String albumId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(standardAlbumActionsProvider.notifier).addPage(albumId),
      child: DottedBorderBox(
        isDark: isDark,
        accent: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        child: Icon(
          Icons.add_rounded,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          size: 26,
        ),
      ),
    );
  }
}

/// Dashed-look placeholder tile shared by empty pages and the "add page" tile.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.isDark,
    required this.accent,
    required this.child,
  });

  final bool isDark;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(child: child),
    );
  }
}
