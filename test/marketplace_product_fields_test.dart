import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/marketplace/models/marketplace_product.dart';

void main() {
  group('MarketplaceProduct Recommendation Fields (LM2-149)', () {
    test('legacy product without new fields parses with defaults', () {
      final data = {
        'sku': 'LEGACY_01',
        'name': 'Biberon classique',
        'description': 'Biberon en verre',
        'priceDZD': 1800,
        'partnerId': 'partner_1',
        'category': 'puericulture',
      };

      final product = MarketplaceProduct.fromMap(data, id: 'prod_legacy');
      expect(product, isNotNull);
      expect(product!.audience, 'child');
      expect(product.ageMinMonths, isNull);
      expect(product.ageMaxMonths, isNull);
      expect(product.pregnancyTrimesters, isEmpty);
      expect(product.skills, isEmpty);
      expect(product.benefitsFr, isEmpty);
      expect(product.benefitsAr, isEmpty);
      expect(product.benefitsEn, isEmpty);
      expect(product.fitsChildAge(6), isTrue); // default 0..999 fits any age
    });

    test('parses audience, ages, skills and benefits', () {
      final data = {
        'sku': 'MONT_01',
        'name': 'Hochet d’éveil en bois',
        'description': 'Stimulation motricité',
        'priceDZD': 2500,
        'partnerId': 'partner_montessori',
        'category': 'eveil',
        'audience': 'child',
        'ageMinMonths': 3,
        'ageMaxMonths': 12,
        'pregnancyTrimesters': <int>[],
        'skills': ['motricite_fine', 'sensoriel'],
        'benefitsFr': ['Développe la préhension', 'Matériaux non toxiques'],
        'benefitsAr': ['تنمية حاسة اللمس', 'خشب طبيعي آمن'],
        'benefitsEn': ['Improves fine motor skills', 'Non-toxic wood'],
      };

      final product = MarketplaceProduct.fromMap(data, id: 'prod_hochet');
      expect(product, isNotNull);
      expect(product!.audience, 'child');
      expect(product.ageMinMonths, 3);
      expect(product.ageMaxMonths, 12);
      expect(product.skills, containsAll(['motricite_fine', 'sensoriel']));
      expect(product.benefitsFr.length, 2);
      expect(product.benefitsFor('fr'), contains('Développe la préhension'));
      expect(product.benefitsFor('ar'), contains('تنمية حاسة اللمس'));
      expect(product.benefitsFor('en'), contains('Improves fine motor skills'));
    });

    test('benefitsFor falls back to highlights when benefits are empty', () {
      final data = {
        'name': 'Tétine physiologique',
        'description': 'Silicone médical',
        'priceDZD': 1200,
        'partnerId': 'partner_tetine',
        'category': 'puericulture',
        'highlights': ['Silicone souple', 'Sans BPA'],
      };

      final product = MarketplaceProduct.fromMap(data, id: 'prod_tetine');
      expect(product, isNotNull);
      expect(product!.benefitsFr, isEmpty);
      expect(product.benefitsFor('fr'), containsAll(['Silicone souple', 'Sans BPA']));
      expect(product.benefitsFor('ar'), containsAll(['Silicone souple', 'Sans BPA']));
    });

    test('fitsChildAge respects bounds and audience', () {
      final data = {
        'name': 'Tapis d’éveil',
        'description': 'Grand tapis molletonné',
        'priceDZD': 6500,
        'partnerId': 'partner_tapis',
        'category': 'eveil',
        'audience': 'child',
        'ageMinMonths': 2,
        'ageMaxMonths': 9,
      };

      final product = MarketplaceProduct.fromMap(data, id: 'prod_tapis')!;
      expect(product.fitsChildAge(1), isFalse); // Below ageMinMonths
      expect(product.fitsChildAge(2), isTrue);  // Exact min
      expect(product.fitsChildAge(6), isTrue);  // In range
      expect(product.fitsChildAge(9), isTrue);  // Exact max
      expect(product.fitsChildAge(10), isFalse); // Above ageMaxMonths
    });

    test('mother audience never fits a child age', () {
      final data = {
        'name': 'Tisane allaitement bio',
        'description': 'Plantes galactogènes',
        'priceDZD': 1400,
        'partnerId': 'partner_maman',
        'category': 'maman',
        'audience': 'mother',
        'ageMinMonths': 0,
        'ageMaxMonths': 36,
      };

      final product = MarketplaceProduct.fromMap(data, id: 'prod_tisane')!;
      expect(product.fitsChildAge(0), isFalse);
      expect(product.fitsChildAge(6), isFalse);
      expect(product.fitsChildAge(12), isFalse);
    });
  });
}
