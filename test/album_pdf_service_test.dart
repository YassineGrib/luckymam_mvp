import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/print_album/services/album_pdf_service.dart';
import 'package:pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlbumPdfService Tests (LM-ALB-006)', () {
    final pdfService = AlbumPdfService();

    test('generates valid PDF document with Latin and French content', () async {
      final bytes = await pdfService.generateAlbumPdf(
        albumTitle: 'Mon Premier Année',
        childName: 'Camille',
        pages: const [
          AlbumPdfPage(
            imageUrl: 'https://example.com/photo1.jpg',
            caption: 'Premier pas au parc',
          ),
          AlbumPdfPage(
            imageUrl: 'https://example.com/photo2.jpg',
            caption: 'Fête d\'anniversaire',
          ),
        ],
        pageFormat: PdfPageFormat.a4,
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF signature check '%PDF-'
      expect(bytes.length, greaterThan(100));
      final header = String.fromCharCodes(bytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('generates valid PDF document with Arabic (RTL) content without crash', () async {
      final bytes = await pdfService.generateAlbumPdf(
        albumTitle: 'ألبومي الأول',
        childName: 'ياسمين',
        pages: const [
          AlbumPdfPage(
            imageUrl: 'https://example.com/photo1.jpg',
            caption: 'أول ابتسامة جميلة',
          ),
          AlbumPdfPage(
            imageUrl: 'https://example.com/photo2.jpg',
            caption: 'يوم العيد مع العائلة',
          ),
        ],
        pageFormat: PdfPageFormat.a5,
      );

      expect(bytes, isNotNull);
      expect(bytes.isNotEmpty, isTrue);
      final header = String.fromCharCodes(bytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('supports different page formats (A4, A5, A3)', () async {
      final formats = [
        PdfPageFormat.a4,
        PdfPageFormat.a5,
        PdfPageFormat.a3,
      ];

      for (final format in formats) {
        final bytes = await pdfService.generateAlbumPdf(
          albumTitle: 'Souvenirs',
          childName: 'Inès',
          pages: const [
            AlbumPdfPage(imageUrl: 'https://example.com/1.jpg', caption: 'Photo'),
          ],
          pageFormat: format,
        );

        expect(bytes.isNotEmpty, isTrue);
      }
    });
  });
}
