import '../../../core/services/safe_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// One filled page of an album, ready to be laid out in the PDF.
class AlbumPdfPage {
  final String imageUrl;
  final String caption;

  const AlbumPdfPage({required this.imageUrl, required this.caption});
}

/// Helper to detect if a text contains Arabic Unicode range characters.
bool _isArabicText(String? text) {
  if (text == null || text.isEmpty) return false;
  return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text);
}

/// Formats date safely without throwing if Intl locale data is not loaded.
String _formatCoverDate(DateTime date, bool isArabic) {
  try {
    return DateFormat('MMMM yyyy', isArabic ? 'ar' : 'fr_FR').format(date);
  } catch (_) {
    final months = isArabic
        ? const [
            'جانفي',
            'فيفري',
            'مارس',
            'أفريل',
            'ماي',
            'جوان',
            'جويلية',
            'أوت',
            'سبتمبر',
            'أكتوبر',
            'نوفمبر',
            'ديسمبر',
          ]
        : const [
            'Janvier',
            'Février',
            'Mars',
            'Avril',
            'Mai',
            'Juin',
            'Juillet',
            'Août',
            'Septembre',
            'Octobre',
            'Novembre',
            'Décembre',
          ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Builds a beautifully laid-out, print-ready PDF photo book from an
/// album's filled pages — a cover, one page per memory, and a closing page.
/// Supports French, Arabic (RTL shaped), and English without character corruption.
class AlbumPdfService {
  static const _brandPink = PdfColor.fromInt(0xFFFF6F91);
  static const _brandCoral = PdfColor.fromInt(0xFFFF8E72);
  static const _ink = PdfColor.fromInt(0xFF2D2A32);
  static const _muted = PdfColor.fromInt(0xFF8B8794);

  /// LM-ALB-003: Calibrated watermark opacity in print safe margins
  static const double watermarkOpacity = 0.38;
  static const String brandWatermarkText = 'LuckyMam';

  Future<Uint8List> generateAlbumPdf({
    required String albumTitle,
    required String childName,
    required List<AlbumPdfPage> pages,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    // 1. Load Arabic and Latin compatible TTF fonts to prevent Unicode crashes
    pw.Font? ttfRegular;
    pw.Font? ttfBold;
    try {
      final regularData =
          await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
      final boldData =
          await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
      ttfRegular = pw.Font.ttf(regularData);
      ttfBold = pw.Font.ttf(boldData);
    } catch (e) {
      safeDebugPrint('[AlbumPdfService] Font loading fallback: ${e.runtimeType}');
    }

    final doc = pw.Document(
      theme: ttfRegular != null
          ? pw.ThemeData.withFont(
              base: ttfRegular,
              bold: ttfBold ?? ttfRegular,
            )
          : null,
    );

    // 2. Load branding logo gracefully
    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo/vertical_logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      safeDebugPrint('[AlbumPdfService] Logo asset loading fallback: ${e.runtimeType}');
    }

    // 3. Fetch photos safely in parallel with timeouts
    final photoBytes = await Future.wait(
      pages.map((p) => _fetchImage(p.imageUrl)),
    );

    final fontBold = ttfBold ?? pw.Font.helveticaBold();
    final fontRegular = ttfRegular ?? pw.Font.helvetica();

    // 4. Build Cover Page
    doc.addPage(
      _buildCoverPage(
        albumTitle: albumTitle,
        childName: childName,
        logo: logo,
        pageFormat: pageFormat,
        fontBold: fontBold,
        fontRegular: fontRegular,
      ),
    );

    // 5. Build Memory Pages (without visible page numbering — LM-ALB-005)
    for (var i = 0; i < pages.length; i++) {
      final bytes = photoBytes[i];
      doc.addPage(
        _buildPhotoPage(
          image: bytes != null ? pw.MemoryImage(bytes) : null,
          caption: pages[i].caption,
          pageFormat: pageFormat,
          fontBold: fontBold,
          fontRegular: fontRegular,
          logo: logo,
        ),
      );
    }

    // 6. Build Closing Page
    doc.addPage(
      _buildClosingPage(
        childName: childName,
        albumTitle: albumTitle,
        pageFormat: pageFormat,
        fontBold: fontBold,
        fontRegular: fontRegular,
      ),
    );

    return doc.save();
  }

  Future<Uint8List?> _fetchImage(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;
      final response =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      safeDebugPrint('[AlbumPdfService] Failed to load image $url: ${e.runtimeType}');
    }
    return null;
  }

  pw.Page _buildCoverPage({
    required String albumTitle,
    required String childName,
    required pw.MemoryImage? logo,
    required PdfPageFormat pageFormat,
    required pw.Font fontBold,
    required pw.Font fontRegular,
  }) {
    final isArabic = _isArabicText(albumTitle) || _isArabicText(childName);

    return pw.Page(
      pageFormat: pageFormat,
      build: (context) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_brandPink, _brandCoral],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Container(
                    width: 90,
                    height: 90,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                pw.SizedBox(height: 36),
                pw.Text(
                  'LUCKYMAM',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    letterSpacing: 4,
                    font: fontBold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 50),
                  child: pw.Text(
                    albumTitle,
                    textAlign: pw.TextAlign.center,
                    textDirection: _isArabicText(albumTitle)
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 28,
                      font: fontBold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  childName,
                  textDirection: _isArabicText(childName)
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    font: fontRegular,
                  ),
                ),
                pw.SizedBox(height: 44),
                pw.Container(width: 44, height: 2, color: PdfColors.white),
                pw.SizedBox(height: 16),
                pw.Text(
                  _formatCoverDate(DateTime.now(), isArabic),
                  textDirection:
                      isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    font: fontRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  pw.Page _buildPhotoPage({
    required pw.MemoryImage? image,
    required String caption,
    required PdfPageFormat pageFormat,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    pw.MemoryImage? logo,
  }) {
    final isArabic = _isArabicText(caption);

    return pw.Page(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.all(0),
      build: (context) {
        return pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.fromLTRB(36, 44, 36, 32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: _brandPink, width: 2.2),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromInt(0x1A000000),
                        blurRadius: 10,
                        offset: const PdfPoint(0, 4),
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: image != null
                      ? pw.Image(image, fit: pw.BoxFit.cover)
                      : pw.Center(
                          child: pw.Text(
                            isArabic
                                ? 'الصورة غير متوفرة'
                                : 'Photo temporairement indisponible',
                            textDirection: isArabic
                                ? pw.TextDirection.rtl
                                : pw.TextDirection.ltr,
                            style: pw.TextStyle(
                              color: _muted,
                              fontSize: 12,
                              font: fontRegular,
                            ),
                          ),
                        ),
                ),
              ),
              if (caption.trim().isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text(
                  caption,
                  textAlign: pw.TextAlign.center,
                  textDirection: isArabic
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 15,
                    font: fontBold,
                  ),
                ),
              ],
              pw.SizedBox(height: 10),
              // Discreet LuckyMam clover watermark in safe margin (LM-ALB-003)
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Opacity(
                  opacity: watermarkOpacity,
                  child: logo != null
                      ? pw.Container(
                          width: 14,
                          height: 14,
                          child: pw.Image(logo, fit: pw.BoxFit.contain),
                        )
                      : pw.Text(
                          brandWatermarkText,
                          style: pw.TextStyle(
                            color: _muted,
                            fontSize: 8.5,
                            font: fontRegular,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildClosingPage({
    required String childName,
    required String albumTitle,
    required PdfPageFormat pageFormat,
    required pw.Font fontBold,
    required pw.Font fontRegular,
  }) {
    final isArabic = _isArabicText(childName) || _isArabicText(albumTitle);

    return pw.Page(
      pageFormat: pageFormat,
      build: (context) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_brandCoral, _brandPink],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  isArabic
                      ? 'شكراً لكونك جزءاً من رحلتنا،'
                      : 'Merci d\'avoir grandi avec nous,',
                  textDirection: isArabic
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    font: fontRegular,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  childName,
                  textDirection: _isArabicText(childName)
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    font: fontBold,
                  ),
                ),
                pw.SizedBox(height: 36),
                pw.Text(
                  isArabic
                      ? 'ذكرى غالية مطبوعة بكل حب وعناية.'
                      : 'Un souvenir précieux, imprimé avec soin.',
                  textDirection: isArabic
                      ? pw.TextDirection.rtl
                      : pw.TextDirection.ltr,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    font: fontRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
