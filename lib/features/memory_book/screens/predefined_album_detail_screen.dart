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
import '../data/album_templates_data.dart';
import '../models/album_template.dart';
import '../models/predefined_album.dart';
import '../providers/predefined_album_providers.dart';
import '../widgets/capsule_picker_sheet.dart';
import '../widgets/album_print_cta.dart';

/// Shows a predefined album's event slots and lets the mother fill each one
/// by attaching an existing capsule or creating a new one.
class PredefinedAlbumDetailScreen extends ConsumerWidget {
  const PredefinedAlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.childId,
  });

  final String albumId;
  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final albumAsync = ref.watch(predefinedAlbumProvider(albumId));

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
          final template = findAlbumTemplate(album.templateId);
          if (template == null) {
            return Center(
              child: Text(l10n.albumTemplateNotFound),
            );
          }
          return _AlbumBody(album: album, template: template);
        },
      ),
    );
  }
}

class _AlbumBody extends ConsumerWidget {
  const _AlbumBody({required this.album, required this.template});

  final PredefinedAlbum album;
  final AlbumTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final sortedSlots = [...template.slots]
      ..sort((a, b) => a.order.compareTo(b.order));
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
      for (final slot in sortedSlots) {
        final capsuleId = album.slotCapsules[slot.id];
        if (capsuleId == null) continue;
        final capsule = capsuleList.where((c) => c.id == capsuleId).firstOrNull;
        if (capsule == null) continue;
        printPages.add(
          AlbumPdfPage(imageUrl: capsule.photoUrl, caption: slot.getTitle(lang)),
        );
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: template.gradientColors.first,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: template.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(template.icon, color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        template.getTitle(lang),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.albumEventsFilledProgress(
                          album.filledCount,
                          template.slotCount,
                        ),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.md,
            AppSpacing.screenPaddingH,
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final slot = sortedSlots[index];
              final capsuleId = album.slotCapsules[slot.id];

              Capsule? capsule;
              if (capsuleId != null) {
                capsule = capsulesAsync.whenOrNull(
                  data: (list) =>
                      list.where((c) => c.id == capsuleId).firstOrNull,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: capsule != null
                    ? _FilledSlotCard(
                        slot: slot,
                        capsule: capsule,
                        accentColor: template.gradientColors.first,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        isDark: isDark,
                        lang: lang,
                      )
                    : _EmptySlotCard(
                        slot: slot,
                        album: album,
                        template: template,
                        accentColor: template.gradientColors.first,
                        textColor: textColor,
                        secondaryText: secondaryText,
                        isDark: isDark,
                        lang: lang,
                      ),
              );
            }, childCount: sortedSlots.length),
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
              albumType: 'predefined',
              albumTitle: template.getTitle(lang),
              pages: printPages,
              accentColor: template.gradientColors.first,
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilledSlotCard extends StatelessWidget {
  const _FilledSlotCard({
    required this.slot,
    required this.capsule,
    required this.accentColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.lang,
  });

  final AlbumEventSlot slot;
  final Capsule capsule;
  final Color accentColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CapsuleDetailScreen(capsule: capsule)),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                capsule.photoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.getTitle(lang),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.albumMemoryAttached,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: secondaryText),
          ],
        ),
      ),
    );
  }
}

class _EmptySlotCard extends ConsumerWidget {
  const _EmptySlotCard({
    required this.slot,
    required this.album,
    required this.template,
    required this.accentColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.lang,
  });

  final AlbumEventSlot slot;
  final PredefinedAlbum album;
  final AlbumTemplate template;
  final Color accentColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(slot.icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.getTitle(lang),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      slot.getDescription(lang),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickExisting(context, ref),
                  icon: Icon(
                    Icons.photo_library_outlined,
                    size: 16,
                    color: accentColor,
                  ),
                  label: Text(
                    l10n.albumExistingCapsule,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createNew(context),
                  icon: const Icon(
                    Icons.add_a_photo_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    l10n.albumNewCapsule,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickExisting(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CapsulePickerSheet(
        childId: album.childId,
        onSelected: (capsule) {
          ref
              .read(predefinedAlbumActionsProvider.notifier)
              .attachCapsuleToSlot(
                albumId: album.id,
                slotId: slot.id,
                capsuleId: capsule.id,
                templateId: template.id,
                method: 'existing',
              );
        },
      ),
    );
  }

  void _createNew(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCapsuleScreen(
          albumId: album.id,
          albumSlotId: slot.id,
          albumType: 'predefined',
          preselectedChildId: album.childId,
        ),
      ),
    );
  }
}
