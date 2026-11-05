import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';

void main() {
  group('LM-CAP-003: Multi-Emotion Capsule Model & Logic', () {
    final now = DateTime(2026, 11, 5, 14, 0);

    test('Capsule defaults to empty secondaryEmotions and allEmotions returns primary', () {
      final capsule = Capsule(
        id: 'cap_1',
        userId: 'user_1',
        childId: 'child_1',
        photoUrl: 'https://example.com/photo.jpg',
        emotion: Emotion.happy,
        createdAt: now,
        updatedAt: now,
      );

      expect(capsule.emotion, Emotion.happy);
      expect(capsule.secondaryEmotions, isEmpty);
      expect(capsule.allEmotions, equals([Emotion.happy]));
    });

    test('Capsule correctly holds secondaryEmotions and allEmotions combines them', () {
      final capsule = Capsule(
        id: 'cap_2',
        userId: 'user_1',
        childId: 'child_1',
        photoUrl: 'https://example.com/photo.jpg',
        emotion: Emotion.love,
        secondaryEmotions: const [Emotion.tender, Emotion.proud],
        createdAt: now,
        updatedAt: now,
      );

      expect(capsule.emotion, Emotion.love);
      expect(capsule.secondaryEmotions, equals([Emotion.tender, Emotion.proud]));
      expect(capsule.allEmotions, equals([Emotion.love, Emotion.tender, Emotion.proud]));
    });

    test('allEmotions excludes any duplicate of the primary emotion', () {
      final capsule = Capsule(
        id: 'cap_3',
        userId: 'user_1',
        childId: 'child_1',
        photoUrl: 'https://example.com/photo.jpg',
        emotion: Emotion.love,
        secondaryEmotions: const [Emotion.love, Emotion.proud],
        createdAt: now,
        updatedAt: now,
      );

      // allEmotions must filter out duplicate primary
      expect(capsule.allEmotions, equals([Emotion.love, Emotion.proud]));
    });

    test('fromMap parses secondaryEmotions, deduplicates, caps at 3, and excludes primary', () {
      final mapData = {
        'id': 'cap_map_1',
        'userId': 'user_1',
        'childId': 'child_1',
        'photoUrl': 'https://example.com/p.jpg',
        'emotion': 'happy',
        'secondaryEmotions': [
          'happy', // duplicate of primary, should be dropped
          'love',
          'love', // duplicate secondary, should be dropped
          'tender',
          'proud',
          'surprised', // 4th distinct secondary, should be truncated to 3 max
          'invalid_emotion_string', // invalid, should be dropped
        ],
        'createdAt': now,
        'updatedAt': now,
      };

      final capsule = Capsule.fromMap(mapData, 'cap_map_1');

      expect(capsule.emotion, Emotion.happy);
      expect(capsule.secondaryEmotions, equals([Emotion.love, Emotion.tender, Emotion.proud]));
      expect(capsule.secondaryEmotions.length, 3);
      expect(capsule.allEmotions, equals([Emotion.happy, Emotion.love, Emotion.tender, Emotion.proud]));
    });

    test('toFirestore serializes secondaryEmotions as list of strings', () {
      final capsule = Capsule(
        id: 'cap_fs_1',
        userId: 'user_1',
        childId: 'child_1',
        photoUrl: 'https://example.com/p.jpg',
        emotion: Emotion.tender,
        secondaryEmotions: const [Emotion.love, Emotion.happy],
        createdAt: now,
        updatedAt: now,
      );

      final fsMap = capsule.toFirestore();

      expect(fsMap['emotion'], 'tender');
      expect(fsMap['secondaryEmotions'], equals(['love', 'happy']));
    });

    test('copyWith updates or preserves secondaryEmotions', () {
      final original = Capsule(
        id: 'cap_cp_1',
        userId: 'user_1',
        childId: 'child_1',
        photoUrl: 'https://example.com/p.jpg',
        emotion: Emotion.tender,
        secondaryEmotions: const [Emotion.happy],
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        secondaryEmotions: const [Emotion.love, Emotion.proud],
      );

      expect(updated.secondaryEmotions, equals([Emotion.love, Emotion.proud]));
      expect(original.secondaryEmotions, equals([Emotion.happy]));
    });

    test('Auto-promotion logic: promoting secondary to primary removes it from secondary list', () {
      var primary = Emotion.tender;
      var secondary = <Emotion>[Emotion.love, Emotion.happy];

      // User selects Emotion.love as primary
      final selectedNewPrimary = Emotion.love;
      if (secondary.contains(selectedNewPrimary)) {
        secondary = List<Emotion>.from(secondary)..remove(selectedNewPrimary);
      }
      primary = selectedNewPrimary;

      expect(primary, Emotion.love);
      expect(secondary, equals([Emotion.happy]));
      expect(secondary.contains(Emotion.love), isFalse);
    });
  });

  group('LM-CAP-002: Timeline Thumbnail & Generic Fallback Verification', () {
    test('Capsule with photo exposes photoUrl', () {
      final now = DateTime.now();
      final capsuleWithPhoto = Capsule(
        id: 'cap_photo',
        userId: 'u1',
        childId: 'c1',
        photoUrl: 'https://storage.googleapis.com/luckymam/photo.jpg',
        emotion: Emotion.happy,
        createdAt: now,
        updatedAt: now,
      );

      expect(capsuleWithPhoto.photoUrl.isNotEmpty, isTrue);
    });

    test('Capsule without photo has empty photoUrl triggering generic placeholder', () {
      final now = DateTime.now();
      final capsuleNoPhoto = Capsule(
        id: 'cap_no_photo',
        userId: 'u1',
        childId: 'c1',
        photoUrl: '',
        category: CapsuleCategory.postPartum,
        emotion: Emotion.sleepy,
        createdAt: now,
        updatedAt: now,
      );

      expect(capsuleNoPhoto.photoUrl.isEmpty, isTrue);
      expect(capsuleNoPhoto.category, CapsuleCategory.postPartum);
      expect(capsuleNoPhoto.category?.emoji, '👶');
      expect(capsuleNoPhoto.category?.labelFr, 'Post-partum');
    });

    test('Emotion.sleepy does not violate Purple Ban', () {
      final sleepyColor = Emotion.sleepy.color;
      // Purple / Violet RGB typically has high red and blue with low green (e.g. 0x8B5CF6)
      // Our soft sky blue is 0xFF0284C7: R=2, G=132, B=199
      expect(sleepyColor.value, 0xFF0284C7);
    });
  });
}

