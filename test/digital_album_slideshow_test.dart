import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/digital_album/models/digital_slideshow_model.dart';

void main() {
  group('LM-DIG-001: Digital Album & Slideshow Specifications (EPIC 7)', () {
    test('DigitalSlideshow enforces minimum 3 photos and maximum 12 photos', () {
      expect(DigitalSlideshow.minPhotos, 3);
      expect(DigitalSlideshow.maxPhotos, 12);

      // 2 photos -> Invalid (< 3)
      final twoPhotos = DigitalSlideshow(
        childId: 'child_1',
        childName: 'Sarah',
        title: 'Diaporama',
        slides: List.generate(
          2,
          (i) => DigitalSlide(
            id: 's_$i',
            photoUrl: 'https://example.com/$i.jpg',
            title: 'Photo $i',
            order: i + 1,
          ),
        ),
      );
      expect(twoPhotos.isValidCount, isFalse);

      // 3 photos -> Valid (min bound)
      final threePhotos = DigitalSlideshow(
        childId: 'child_1',
        childName: 'Sarah',
        title: 'Diaporama',
        slides: List.generate(
          3,
          (i) => DigitalSlide(
            id: 's_$i',
            photoUrl: 'https://example.com/$i.jpg',
            title: 'Photo $i',
            order: i + 1,
          ),
        ),
      );
      expect(threePhotos.isValidCount, isTrue);

      // 12 photos -> Valid (max bound)
      final twelvePhotos = DigitalSlideshow(
        childId: 'child_1',
        childName: 'Sarah',
        title: 'Diaporama',
        slides: List.generate(
          12,
          (i) => DigitalSlide(
            id: 's_$i',
            photoUrl: 'https://example.com/$i.jpg',
            title: 'Photo $i',
            order: i + 1,
          ),
        ),
      );
      expect(twelvePhotos.isValidCount, isTrue);

      // 13 photos -> Invalid (> 12)
      final thirteenPhotos = DigitalSlideshow(
        childId: 'child_1',
        childName: 'Sarah',
        title: 'Diaporama',
        slides: List.generate(
          13,
          (i) => DigitalSlide(
            id: 's_$i',
            photoUrl: 'https://example.com/$i.jpg',
            title: 'Photo $i',
            order: i + 1,
          ),
        ),
      );
      expect(thirteenPhotos.isValidCount, isFalse);
    });

    test('DigitalSlideshow default duration is exactly 3.5 seconds (3500ms)', () {
      final slideshow = DigitalSlideshow(
        childId: 'child_1',
        childName: 'Yanis',
        title: 'Diaporama',
        slides: [
          const DigitalSlide(id: '1', photoUrl: 'url', title: '1'),
          const DigitalSlide(id: '2', photoUrl: 'url', title: '2'),
          const DigitalSlide(id: '3', photoUrl: 'url', title: '3'),
        ],
      );
      expect(slideshow.durationPerSlide, const Duration(milliseconds: 3500));
    });

    test('DigitalSlide copyWith properly updates fields and preserves unchanged', () {
      const original = DigitalSlide(
        id: 'orig_1',
        photoUrl: 'https://example.com/orig.jpg',
        title: 'Premier pas',
        order: 1,
      );

      final updated = original.copyWith(order: 4, title: 'Premiers pas de géant');
      expect(updated.id, 'orig_1');
      expect(updated.photoUrl, 'https://example.com/orig.jpg');
      expect(updated.title, 'Premiers pas de géant');
      expect(updated.order, 4);
    });
  });
}

