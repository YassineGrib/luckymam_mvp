import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/profile/models/pregnancy.dart';

Pregnancy _p({
  String id = 'preg_1',
  required DateTime lmp,
  DateTime? edd,
  EddSource eddSource = EddSource.lmp,
  int babyCount = 1,
  List<String> childIds = const [],
  PregnancyStatus status = PregnancyStatus.active,
  DateTime? endedAt,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final defaultTs = DateTime(2026, 1, 1);
  return Pregnancy(
    id: id,
    lmpDate: lmp,
    eddDate: edd ?? Pregnancy.eddFromLmp(lmp),
    eddSource: eddSource,
    babyCount: babyCount,
    childIds: childIds,
    status: status,
    endedAt: endedAt,
    createdAt: createdAt ?? defaultTs,
    updatedAt: updatedAt ?? defaultTs,
  );
}

void main() {
  group('Pregnancy gestational maths', () {
    test('eddFromLmp adds 280 days', () {
      expect(
        Pregnancy.eddFromLmp(DateTime(2026, 1, 1)),
        DateTime(2026, 10, 8),
      );
    });

    test('gestational week and day', () {
      final p = _p(lmp: DateTime(2026, 1, 1));
      expect(p.gestationalWeek(DateTime(2026, 3, 5)), 9); // 63 days
      expect(p.gestationalDay(DateTime(2026, 3, 5)), 0);
      expect(p.trimester(DateTime(2026, 3, 5)), 1);
    });

    test('clamps future lmp to week 0', () {
      expect(
        _p(lmp: DateTime(2026, 5, 1)).gestationalWeek(DateTime(2026, 4, 1)),
        0,
      );
    });

    test('overdue gives negative daysUntilDue and week capped at 42', () {
      final p = _p(lmp: DateTime(2025, 1, 1));
      expect(p.daysUntilDue(DateTime(2026, 1, 1)) < 0, isTrue);
      expect(p.gestationalWeek(DateTime(2026, 1, 1)), 42);
    });

    test('trimester boundaries: 1 (0-13), 2 (14-27), 3 (28+)', () {
      final p = _p(lmp: DateTime(2026, 1, 1));
      // week 13: 13 * 7 = 91 days -> 2026-04-02
      expect(p.trimester(DateTime(2026, 4, 2)), 1);
      // week 14: 14 * 7 = 98 days -> 2026-04-09
      expect(p.trimester(DateTime(2026, 4, 9)), 2);
      // week 27: 27 * 7 = 189 days -> 2026-07-09
      expect(p.trimester(DateTime(2026, 7, 9)), 2);
      // week 28: 28 * 7 = 196 days -> 2026-07-16
      expect(p.trimester(DateTime(2026, 7, 16)), 3);
    });

    test('isActive reflects status', () {
      expect(
        _p(lmp: DateTime(2026, 1, 1), status: PregnancyStatus.active).isActive,
        isTrue,
      );
      expect(
        _p(
          lmp: DateTime(2026, 1, 1),
          status: PregnancyStatus.delivered,
        ).isActive,
        isFalse,
      );
      expect(
        _p(lmp: DateTime(2026, 1, 1), status: PregnancyStatus.ended).isActive,
        isFalse,
      );
    });
  });

  group('Pregnancy Firestore serialization', () {
    test('firestore round trip keeps fields', () {
      final p = Pregnancy(
        id: 'p_123',
        lmpDate: DateTime(2026, 2, 14),
        eddDate: DateTime(2026, 11, 21),
        eddSource: EddSource.ultrasound,
        babyCount: 2,
        childIds: const ['child_a', 'child_b'],
        status: PregnancyStatus.active,
        endedAt: null,
        createdAt: DateTime(2026, 2, 15, 10, 0),
        updatedAt: DateTime(2026, 2, 15, 10, 0),
      );

      final map = p.toFirestore();
      expect(map['lmpDate'], isA<Timestamp>());
      expect(map['eddDate'], isA<Timestamp>());
      expect(map['eddSource'], 'ultrasound');
      expect(map['babyCount'], 2);
      expect(map['childIds'], ['child_a', 'child_b']);
      expect(map['status'], 'active');
      expect(map['endedAt'], isNull);

      final restored = Pregnancy.fromFirestore(map, 'p_123');
      expect(restored.id, p.id);
      expect(restored.lmpDate, p.lmpDate);
      expect(restored.eddDate, p.eddDate);
      expect(restored.eddSource, p.eddSource);
      expect(restored.babyCount, p.babyCount);
      expect(restored.childIds, p.childIds);
      expect(restored.status, p.status);
      expect(restored.endedAt, isNull);
      expect(restored.createdAt, p.createdAt);
      expect(restored.updatedAt, p.updatedAt);
      expect(restored, equals(p));
    });

    test(
      'fromFirestore falls back gracefully on unknown enum values or missing fields',
      () {
        final data = <String, dynamic>{
          'lmpDate': Timestamp.fromDate(DateTime(2026, 3, 1)),
          'eddSource': 'unknown_source',
          'status': 'unknown_status',
        };
        final p = Pregnancy.fromFirestore(data, 'p_fallback');
        expect(p.eddSource, EddSource.lmp);
        expect(p.status, PregnancyStatus.active);
        expect(p.babyCount, 1);
        expect(p.childIds, isEmpty);
        expect(p.eddDate, Pregnancy.eddFromLmp(DateTime(2026, 3, 1)));
      },
    );

    test('copyWith updates fields while preserving others', () {
      final original = _p(lmp: DateTime(2026, 1, 1));
      final updated = original.copyWith(
        babyCount: 2,
        status: PregnancyStatus.delivered,
      );
      expect(updated.id, original.id);
      expect(updated.lmpDate, original.lmpDate);
      expect(updated.babyCount, 2);
      expect(updated.status, PregnancyStatus.delivered);
    });
  });
}
