import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';

Capsule _capsule({
  String id = 'test_id',
  String userId = 'user_1',
  String childId = 'child_1',
  List<String> childIds = const [],
  bool withMother = false,
  String? pregnancyId,
  int? pregnancyWeek,
  String photoUrl = 'https://example.com/photo.jpg',
  String? audioUrl,
  int? audioDuration,
  Emotion emotion = Emotion.happy,
  List<String> tags = const [],
  bool isFavorite = false,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? capturedAt,
  CapsuleCategory? category,
}) {
  final now = DateTime(2026, 10, 21);
  return Capsule(
    id: id,
    userId: userId,
    childId: childId,
    childIds: childIds,
    withMother: withMother,
    pregnancyId: pregnancyId,
    pregnancyWeek: pregnancyWeek,
    photoUrl: photoUrl,
    audioUrl: audioUrl,
    audioDuration: audioDuration,
    emotion: emotion,
    tags: tags,
    isFavorite: isFavorite,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    capturedAt: capturedAt,
    category: category,
  );
}

Capsule fromMap(Map<String, dynamic> data, [String id = 'test_id']) =>
    Capsule.fromMap(data, id);

void main() {
  group('CapsuleSpace enum', () {
    test('defines child, mother, and family spaces', () {
      expect(CapsuleSpace.values, [
        CapsuleSpace.child,
        CapsuleSpace.mother,
        CapsuleSpace.family,
      ]);
      expect(CapsuleSpace.child.name, 'child');
      expect(CapsuleSpace.mother.name, 'mother');
      expect(CapsuleSpace.family.name, 'family');
    });
  });

  group('deriveCapsuleSpace rule ordering', () {
    test(
        'Rule 1: bump photo with pregnancyId, withMother and 1 child stays in mother space',
        () {
      expect(
        deriveCapsuleSpace(
          childIds: ['baby2'],
          withMother: true,
          pregnancyId: 'preg_123',
        ),
        CapsuleSpace.mother,
      );
    });

    test(
        'Rule 2: siblings (>= 2 children) without mother are family space',
        () {
      expect(
        deriveCapsuleSpace(
          childIds: ['amine', 'sara'],
          withMother: false,
        ),
        CapsuleSpace.family,
      );
    });

    test('Rule 2: >= 2 children with mother are family space', () {
      expect(
        deriveCapsuleSpace(
          childIds: ['amine', 'sara'],
          withMother: true,
        ),
        CapsuleSpace.family,
      );
    });

    test(
        'Rule 2: >= 2 children even with pregnancyId are family space',
        () {
      expect(
        deriveCapsuleSpace(
          childIds: ['baby1', 'baby2'],
          withMother: true,
          pregnancyId: 'preg_123',
        ),
        CapsuleSpace.family,
      );
    });

    test(
        'Rule 3: mother with single born child (no pregnancyId) is family space',
        () {
      expect(
        deriveCapsuleSpace(
          childIds: ['amine'],
          withMother: true,
        ),
        CapsuleSpace.family,
      );
    });

    test('Rule 4: mother alone is mother space', () {
      expect(
        deriveCapsuleSpace(
          childIds: [],
          withMother: true,
        ),
        CapsuleSpace.mother,
      );
    });

    test('Rule 4: mother alone with pregnancyId is mother space', () {
      expect(
        deriveCapsuleSpace(
          childIds: [],
          withMother: true,
          pregnancyId: 'preg_123',
        ),
        CapsuleSpace.mother,
      );
    });

    test('Rule 5: single child alone is child space', () {
      expect(
        deriveCapsuleSpace(
          childIds: ['amine'],
          withMother: false,
        ),
        CapsuleSpace.child,
      );
    });

    test('Rule 5: empty subjects default to child space', () {
      expect(
        deriveCapsuleSpace(
          childIds: [],
          withMother: false,
        ),
        CapsuleSpace.child,
      );
    });
  });

  group('Capsule.fromMap deserialization', () {
    test('legacy childId backfills childIds', () {
      expect(fromMap({'childId': 'a'}).childIds, ['a']);
    });

    test('empty legacy childId gives empty list', () {
      expect(fromMap({'childId': ''}).childIds, isEmpty);
    });

    test('missing childId and childIds gives empty list', () {
      final c = fromMap({});
      expect(c.childIds, isEmpty);
      expect(c.childId, isEmpty);
    });

    test('explicit childIds list is preserved and childId derives first', () {
      final c = fromMap({
        'childIds': ['child_1', 'child_2'],
      });
      expect(c.childIds, ['child_1', 'child_2']);
      expect(c.childId, 'child_1');
    });

    test('withMother, pregnancyId, and pregnancyWeek parse correctly', () {
      final c = fromMap({
        'childIds': ['baby'],
        'withMother': true,
        'pregnancyId': 'p_42',
        'pregnancyWeek': 24,
      });
      expect(c.withMother, isTrue);
      expect(c.pregnancyId, 'p_42');
      expect(c.pregnancyWeek, 24);
      expect(c.space, CapsuleSpace.mother);
    });

    test('handles Timestamp dates and null defaults gracefully', () {
      final ts = Timestamp.fromDate(DateTime(2026, 5, 1, 10, 0));
      final c = fromMap({
        'childId': 'c1',
        'createdAt': ts,
        'updatedAt': ts,
        'capturedAt': ts,
        'emotion': 'love',
      }, 'custom_id');
      expect(c.id, 'custom_id');
      expect(c.emotion, Emotion.love);
      expect(c.createdAt, ts.toDate());
      expect(c.updatedAt, ts.toDate());
      expect(c.capturedAt, ts.toDate());
    });
  });

  group('Capsule construction and backward compatibility', () {
    test('Capsule(childId: a) with no childIds backfills childIds getter', () {
      final c = _capsule(childId: 'a');
      expect(c.childIds, ['a']);
      expect(c.childId, 'a');
      expect(c.space, CapsuleSpace.child);
    });

    test('toFirestore writes childIds and space when created with legacy childId', () {
      final c = _capsule(childId: 'a');
      final map = c.toFirestore();
      expect(map['childId'], 'a');
      expect(map['childIds'], ['a']);
      expect(map['space'], 'child');
      expect(map['withMother'], false);
      expect(map['pregnancyId'], isNull);
      expect(map['pregnancyWeek'], isNull);
    });

    test('mother-only capsule writes empty childIds, space mother, and withMother true', () {
      final c = _capsule(
        childId: '',
        childIds: const [],
        withMother: true,
      );
      expect(c.childIds, isEmpty);
      expect(c.childId, isEmpty);
      expect(c.space, CapsuleSpace.mother);

      final map = c.toFirestore();
      expect(map['childId'], '');
      expect(map['childIds'], isEmpty);
      expect(map['withMother'], true);
      expect(map['space'], 'mother');
    });

    test('multi-child family capsule writes first childId and space family', () {
      final c = _capsule(
        childId: 'first_child',
        childIds: const ['first_child', 'second_child'],
        withMother: false,
      );
      expect(c.space, CapsuleSpace.family);

      final map = c.toFirestore();
      expect(map['childId'], 'first_child');
      expect(map['childIds'], ['first_child', 'second_child']);
      expect(map['space'], 'family');
    });

    test('bump photo capsule derives mother space and writes pregnancy fields', () {
      final c = _capsule(
        childId: 'expected_baby',
        childIds: const ['expected_baby'],
        withMother: true,
        pregnancyId: 'p_99',
        pregnancyWeek: 28,
      );
      expect(c.space, CapsuleSpace.mother);

      final map = c.toFirestore();
      expect(map['childId'], 'expected_baby');
      expect(map['childIds'], ['expected_baby']);
      expect(map['withMother'], true);
      expect(map['pregnancyId'], 'p_99');
      expect(map['pregnancyWeek'], 28);
      expect(map['space'], 'mother');
    });
  });

  group('Capsule.copyWith', () {
    test('updates new multi-subject fields', () {
      final initial = _capsule(childId: 'c1');
      final updated = initial.copyWith(
        childIds: ['c1', 'c2'],
        withMother: true,
        pregnancyId: 'preg_1',
        pregnancyWeek: 12,
      );

      expect(updated.childIds, ['c1', 'c2']);
      expect(updated.childId, 'c1');
      expect(updated.withMother, isTrue);
      expect(updated.pregnancyId, 'preg_1');
      expect(updated.pregnancyWeek, 12);
      expect(updated.space, CapsuleSpace.family);
    });

    test('updating childId on copyWith updates childIds when childIds is omitted', () {
      final initial = _capsule(childId: 'c1');
      final updated = initial.copyWith(childId: 'c2');

      expect(updated.childId, 'c2');
      expect(updated.childIds, ['c2']);
    });

    test('clearPregnancyId and clearPregnancyWeek clear optional values', () {
      final initial = _capsule(
        childId: 'baby',
        childIds: ['baby'],
        withMother: true,
        pregnancyId: 'preg_1',
        pregnancyWeek: 20,
      );

      final cleared = initial.copyWith(
        clearPregnancyId: true,
        clearPregnancyWeek: true,
      );

      expect(cleared.pregnancyId, isNull);
      expect(cleared.pregnancyWeek, isNull);
      // Without pregnancyId, mother with 1 child derives family
      expect(cleared.space, CapsuleSpace.family);
    });

    test('copyWith(childIds: [], withMother: true) clears children', () {
      final initial = _capsule(childId: 'c1', childIds: ['c1']);
      final updated = initial.copyWith(childIds: [], withMother: true);

      expect(updated.childIds, isEmpty);
      expect(updated.childId, '');
      expect(updated.space, CapsuleSpace.mother);
      expect(updated.toFirestore()['childIds'], isEmpty);
    });
  });
}
