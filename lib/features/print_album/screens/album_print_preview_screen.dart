import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/print_order_providers.dart';
import '../services/album_pdf_service.dart';
import 'print_order_screen.dart';

/// Shows a live, page-flippable preview of the album as it will be printed,
/// then lets the mother move on to finalize the order.
class AlbumPrintPreviewScreen extends ConsumerStatefulWidget {
  const AlbumPrintPreviewScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.albumId,
    required this.albumType,
    required this.albumTitle,
    required this.pages,
  });

  final String childId;
  final String childName;
  final String albumId;

  /// 'predefined' | 'standard'
  final String albumType;
  final String albumTitle;
  final List<AlbumPdfPage> pages;

  @override
  ConsumerState<AlbumPrintPreviewScreen> createState() =>
      _AlbumPrintPreviewScreenState();
}

class _AlbumPrintPreviewScreenState
    extends ConsumerState<AlbumPrintPreviewScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().logEvent(
      'pdf_preview_opened',
      parameters: {'albumId': widget.albumId, 'albumType': widget.albumType},
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

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
              ? 'معاينة الألبوم'
              : lang == 'en'
                  ? 'Album Preview'
                  : 'Aperçu de l\'album',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfPreview(
              build: (format) => ref
                  .read(albumPdfServiceProvider)
                  .generateAlbumPdf(
                    albumTitle: widget.albumTitle,
                    childName: widget.childName,
                    pages: widget.pages,
                  ),
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfPreviewPageDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              loadingWidget: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.magentaPink,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      lang == 'ar'
                          ? 'جاري تجهيز ألبومك...'
                          : lang == 'en'
                              ? 'Preparing your album...'
                              : 'Préparation de votre album...',
                      style: GoogleFonts.outfit(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.magentaPink.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrintOrderScreen(
                          childId: widget.childId,
                          childName: widget.childName,
                          albumId: widget.albumId,
                          albumType: widget.albumType,
                          albumTitle: widget.albumTitle,
                          pageCount: widget.pages.length,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      lang == 'ar'
                          ? 'طلب الطباعة'
                          : lang == 'en'
                              ? 'Order printing'
                              : 'Commander l\'impression',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
