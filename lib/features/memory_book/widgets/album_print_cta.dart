import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../print_album/screens/album_print_preview_screen.dart';
import '../../print_album/services/album_pdf_service.dart';

/// Shared "Commander l'impression" call-to-action used by both predefined
/// and standard album detail screens. Disabled with a hint until at least
/// one page is filled — an empty album can't be printed.
class AlbumPrintCta extends StatelessWidget {
  const AlbumPrintCta({
    super.key,
    required this.childId,
    required this.childName,
    required this.albumId,
    required this.albumType,
    required this.albumTitle,
    required this.pages,
    required this.accentColor,
    required this.isDark,
  });

  final String childId;
  final String childName;
  final String albumId;
  final String albumType;
  final String albumTitle;
  final List<AlbumPdfPage> pages;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (pages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_print_shop_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.albumPrintNeedMemory,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        AnalyticsService().logEvent(
          'album_print_cta_clicked',
          parameters: {
            'albumId': albumId,
            'albumType': albumType,
            'pageCount': pages.length,
          },
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlbumPrintPreviewScreen(
              childId: childId,
              childName: childName,
              albumId: albumId,
              albumType: albumType,
              albumTitle: albumTitle,
              pages: pages,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_print_shop_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.printOrderPrinting,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
