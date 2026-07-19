import 'dart:typed_data';

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

/// Builds a beautifully laid-out, print-ready PDF photo book from an
/// album's filled pages — a cover, one page per memory, and a closing page.
class AlbumPdfService {
  static const _brandPink = PdfColor.fromInt(0xFFFF6F91);
  static const _brandPurple = PdfColor.fromInt(0xFF7C4DFF);
  static const _ink = PdfColor.fromInt(0xFF2D2A32);
  static const _muted = PdfColor.fromInt(0xFF8B8794);

  Future<Uint8List> generateAlbumPdf({
    required String albumTitle,
    required String childName,
    required List<AlbumPdfPage> pages,
  }) async {
    final doc = pw.Document();

    final logoBytes = await rootBundle.load('assets/logo/vertical_logo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Fetch every photo in parallel — this is the slow part.
    final photoBytes = await Future.wait(
      pages.map((p) => _fetchImage(p.imageUrl)),
    );

    doc.addPage(_buildCoverPage(albumTitle, childName, logo));

    for (var i = 0; i < pages.length; i++) {
      final bytes = photoBytes[i];
      if (bytes == null) continue;
      doc.addPage(
        _buildPhotoPage(
          image: pw.MemoryImage(bytes),
          caption: pages[i].caption,
          pageNumber: i + 1,
          totalPages: pages.length,
        ),
      );
    }

    doc.addPage(_buildClosingPage(childName));

    return doc.save();
  }

  Future<Uint8List?> _fetchImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  pw.Page _buildCoverPage(
    String albumTitle,
    String childName,
    pw.MemoryImage logo,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_brandPink, _brandPurple],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
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
                    font: pw.Font.helveticaBold(),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 60),
                  child: pw.Text(
                    albumTitle,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 30,
                      font: pw.Font.helveticaBold(),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  childName,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 15,
                    font: pw.Font.helvetica(),
                  ),
                ),
                pw.SizedBox(height: 50),
                pw.Container(width: 40, height: 1.5, color: PdfColors.white),
                pw.SizedBox(height: 16),
                pw.Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(DateTime.now()),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    font: pw.Font.helvetica(),
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
    required pw.MemoryImage image,
    required String caption,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (context) {
        return pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.fromLTRB(36, 48, 36, 36),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: _brandPink, width: 2.5),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromInt(0x22000000),
                        blurRadius: 12,
                        offset: const PdfPoint(0, 6),
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                caption,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 16,
                  font: pw.Font.helveticaBold(),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '$pageNumber / $totalPages',
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 10,
                  font: pw.Font.helvetica(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildClosingPage(String childName) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_brandPurple, _brandPink],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Merci d\'avoir grandi avec nous,',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    font: pw.Font.helvetica(),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  childName,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Un souvenir précieux, imprimé avec soin.',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    font: pw.Font.helvetica(),
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
