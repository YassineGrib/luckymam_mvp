import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/timeline/models/phase.dart';
import 'package:lukymam_mvp/features/timeline/data/milestones_data.dart';
import 'package:lukymam_mvp/features/timeline/services/timeline_service.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';

void main() {
  group('LM-CAP-001: Timeline and Capsule Linking', () {
    test('allMilestones contains valid milestones with actionType capsule', () {
      final capsuleMilestones =
          allMilestones.where((m) => m.canHaveCapsule).toList();
      expect(capsuleMilestones.isNotEmpty, isTrue);

      final smileMilestone = allMilestones.firstWhere(
        (m) => m.id == 'POST_PREMIER_SOURIRE' || m.id.contains('SOURIRE'),
        orElse: () => allMilestones.first,
      );
      expect(smileMilestone.canHaveCapsule, isTrue);
      expect(smileMilestone.getTitle('fr').isNotEmpty, isTrue);
      expect(smileMilestone.getTitle('ar').isNotEmpty, isTrue);
    });

    test('MilestoneWithDueDate associates capsuleId and completedAt correctly', () {
      final sample = allMilestones.first;
      final completedAt = DateTime(2026, 10, 22, 10, 30);
      const capsuleId = 'cap-12345';

      final milestoneWithDue = MilestoneWithDueDate(
        milestone: sample,
        dueDate: DateTime(2026, 10, 20),
        isCompleted: true,
        capsuleId: capsuleId,
        thumbnailUrl: 'https://example.com/photo.jpg',
        completedAt: completedAt,
      );

      expect(milestoneWithDue.isCompleted, isTrue);
      expect(milestoneWithDue.capsuleId, equals('cap-12345'));
      expect(milestoneWithDue.thumbnailUrl, equals('https://example.com/photo.jpg'));
      expect(milestoneWithDue.completedAt, equals(completedAt));
    });

    test('CapsuleCategory enum matches expected milestone phases', () {
      expect(CapsuleCategory.gestation.name, equals('gestation'));
      expect(CapsuleCategory.postPartum.name, equals('postPartum'));
      expect(CapsuleCategory.enfance.name, equals('enfance'));
    });

    test('TimelineService.determineCapsulePhase smartly maps capsules to phases', () {
      final child = Child(
        id: 'child-1',
        name: 'Adam',
        birthDate: DateTime(2025, 1, 1),
        gender: ChildGender.boy,
      );

      // Explicit category
      final capWithCategory = Capsule(
        id: 'c1',
        userId: 'u1',
        childId: 'child-1',
        photoUrl: 'https://example.com/c1.jpg',
        emotion: Emotion.happy,
        category: CapsuleCategory.postPartum,
        createdAt: DateTime(2025, 3, 1),
        updatedAt: DateTime(2025, 3, 1),
      );
      expect(
        TimelineService.determineCapsulePhase(capWithCategory, child),
        equals(Phase.postPartum),
      );

      // Pregnancy capsule (before birth or with pregnancy week)
      final capGestation = Capsule(
        id: 'c2',
        userId: 'u1',
        childId: 'child-1',
        photoUrl: 'https://example.com/c2.jpg',
        emotion: Emotion.love,
        pregnancyWeek: 20,
        createdAt: DateTime(2024, 8, 1),
        updatedAt: DateTime(2024, 8, 1),
      );
      expect(
        TimelineService.determineCapsulePhase(capGestation, child),
        equals(Phase.gestation),
      );

      // Spontaneous infant memory (3 months after birth)
      final capInfant = Capsule(
        id: 'c3',
        userId: 'u1',
        childId: 'child-1',
        photoUrl: 'https://example.com/c3.jpg',
        emotion: Emotion.tender,
        capturedAt: DateTime(2025, 4, 15),
        createdAt: DateTime(2025, 4, 15),
        updatedAt: DateTime(2025, 4, 15),
      );
      expect(
        TimelineService.determineCapsulePhase(capInfant, child),
        equals(Phase.postPartum),
      );

      // Childhood memory (2 years old)
      final capChild = Capsule(
        id: 'c4',
        userId: 'u1',
        childId: 'child-1',
        photoUrl: 'https://example.com/c4.jpg',
        emotion: Emotion.proud,
        capturedAt: DateTime(2027, 2, 1),
        createdAt: DateTime(2027, 2, 1),
        updatedAt: DateTime(2027, 2, 1),
      );
      expect(
        TimelineService.determineCapsulePhase(capChild, child),
        equals(Phase.enfance),
      );
    });
  });
}
