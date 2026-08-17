import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/album_templates_data.dart';
import '../models/album_template.dart';
import '../providers/predefined_album_providers.dart';
import 'predefined_album_detail_screen.dart';

/// Lets the mother pick a predefined album template to start filling in
/// for a specific child.
class AlbumTemplatePickerScreen extends ConsumerWidget {
  const AlbumTemplatePickerScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

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

    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'ar'
              ? 'ألبوم مسبق الصنع'
              : lang == 'en'
                  ? 'Predefined Album'
                  : 'Album prédéfini',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingH,
          8,
          AppSpacing.screenPaddingH,
          32,
        ),
        children: [
          Text(
            lang == 'ar'
                ? 'اختر نموذجاً لـ $childName'
                : lang == 'en'
                    ? 'Choose a template for $childName'
                    : 'Choisissez un modèle pour $childName',
            style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          ...albumTemplates.map(
            (template) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _TemplateCard(
                template: template,
                lang: lang,
                onTap: () => _selectTemplate(context, ref, template, lang),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTemplate(
    BuildContext context,
    WidgetRef ref,
    AlbumTemplate template,
    String lang,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          lang == 'ar'
              ? 'إنشاء « ${template.getTitle(lang)} » ؟'
              : lang == 'en'
                  ? 'Create "${template.getTitle(lang)}"? '
                  : 'Créer « ${template.getTitle(lang)} » ?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          lang == 'ar'
              ? 'سيتم إنشاء هذا الألبوم لـ $childName مع ${template.slotCount} مناسبة لملئها.'
              : lang == 'en'
                  ? 'This album will be created for $childName with ${template.slotCount} events to fill.'
                  : 'Cet album sera créé pour $childName avec ${template.slotCount} évènements à remplir.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              lang == 'ar'
                  ? 'إلغاء'
                  : lang == 'en'
                      ? 'Cancel'
                      : 'Annuler',
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              lang == 'ar'
                  ? 'إنشاء'
                  : lang == 'en'
                      ? 'Create'
                      : 'Créer',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final album = await ref
        .read(predefinedAlbumActionsProvider.notifier)
        .createAlbum(childId: childId, templateId: template.id);

    if (!context.mounted) return;

    if (album == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'خطأ أثناء إنشاء الألبوم'
                : lang == 'en'
                    ? 'Error creating the album'
                    : 'Erreur lors de la création de l\'album',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            PredefinedAlbumDetailScreen(albumId: album.id, childId: childId),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.lang,
    required this.onTap,
  });

  final AlbumTemplate template;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: template.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: template.gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(template.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.getTitle(lang),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.getSubtitle(lang),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lang == 'ar'
                          ? '${template.slotCount} مناسبات'
                          : lang == 'en'
                              ? '${template.slotCount} events'
                              : '${template.slotCount} évènements',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
