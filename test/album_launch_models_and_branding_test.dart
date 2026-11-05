import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/memory_book/data/album_templates_data.dart';
import 'package:lukymam_mvp/features/print_album/services/album_pdf_service.dart';
import 'package:lukymam_mvp/features/print_album/services/album_pricing_service.dart';

void main() {
  group('LM-ALB-007 & LM-ALB-002: Simplified Initial Offer (Launch Models)', () {
    test('Only exactly 2 predefined templates are flagged as launch models', () {
      final launchModels = albumTemplates.where((t) => t.isLaunchModel).toList();
      expect(launchModels.length, 2);

      final launchIds = launchModels.map((t) => t.id).toSet();
      expect(launchIds, containsAll(['tpl_birth', 'tpl_portrait_1']));
    });

    test('Non-launch templates are marked as coming soon', () {
      final comingSoon = albumTemplates.where((t) => t.isComingSoon).toList();
      expect(comingSoon.length, greaterThanOrEqualTo(2));

      final comingSoonIds = comingSoon.map((t) => t.id).toSet();
      expect(comingSoonIds, containsAll(['tpl_first_year', 'tpl_traditions']));
      for (final t in comingSoon) {
        expect(t.isLaunchModel, isFalse);
      }
    });

    test('tpl_portrait_1 is dedicated 1-photo portrait model with A5/A4/A3 formats', () {
      final portraitTemplate = albumTemplates.firstWhere((t) => t.id == 'tpl_portrait_1');

      expect(portraitTemplate.isSinglePortraitPhoto, isTrue);
      expect(portraitTemplate.slotCount, 1);
      expect(portraitTemplate.startingPriceDa, 440);
      expect(portraitTemplate.supportedFormats, ['A5', 'A4', 'A3']);

      // Official price verification in AlbumPricingService
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A5'), 440);
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A4'), 690);
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A3'), 990);
    });

    test('tpl_birth is dedicated 6-photo album model with A5/A4 formats', () {
      final birthTemplate = albumTemplates.firstWhere((t) => t.id == 'tpl_birth');

      expect(birthTemplate.isSinglePortraitPhoto, isFalse);
      expect(birthTemplate.slotCount, 6);
      expect(birthTemplate.startingPriceDa, 1980);
      expect(birthTemplate.supportedFormats, ['A5', 'A4']);

      // Official price verification in AlbumPricingService
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A5'), 1980);
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A4'), 3030);
      // A3 is not allowed for 6 photos
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A3'), isNull);
    });

    test('Purple Ban Compliance: no template uses purple or violet hues', () {
      final forbiddenHues = [
        0xFF8E44AD,
        0xFF7C4DFF,
        0xFF9C27B0,
        0xFF673AB7,
        0xFF6A1B9A,
      ];

      for (final template in albumTemplates) {
        for (final color in template.gradientColors) {
          expect(
            forbiddenHues.contains(color.toARGB32()),
            isFalse,
            reason: 'Template ${template.id} uses forbidden purple color: $color',
          );
        }
      }
    });
  });

  group('LM-ALB-003: Discrete LuckyMam Clover Watermark & Print Margins', () {
    test('LuckyMam watermark opacity is calibrated to 38% in print safe margins', () {
      expect(AlbumPdfService.watermarkOpacity, 0.38);
      expect(AlbumPdfService.brandWatermarkText, contains('LuckyMam'));
    });
  });
}
