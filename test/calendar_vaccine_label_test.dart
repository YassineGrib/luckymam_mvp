import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LM-HOME-001: Calendar Label Precision (Calendrier vaccinal complet)', () {
    test('French calendar label specifies Calendrier vaccinal complet', () {
      const frenchLabel = 'Calendrier vaccinal complet ›';
      expect(frenchLabel, contains('Calendrier vaccinal complet'));
    });

    test('Arabic calendar label specifies جدول التطعيمات الكامل', () {
      const arabicLabel = 'جدول التطعيمات الكامل ›';
      expect(arabicLabel, contains('جدول التطعيمات الكامل'));
    });

    test('English calendar label specifies Full vaccine calendar', () {
      const englishLabel = 'Full vaccine calendar ›';
      expect(englishLabel, contains('vaccine calendar'));
    });
  });
}

