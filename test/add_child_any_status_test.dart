import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/services/capsule_service.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/subscription/models/subscription_models.dart';

Timestamp _ts(int y, int m, int d) => Timestamp.fromDate(DateTime(y, m, d));

void main() {
  group('LM-ONB-005: Add children across any mother status', () {
    test(
      'Criterion 1 & 2: Multiple children can be associated with MAM profile under all statuses',
      () {
        // 1. Mother in hope (trying to conceive, has 1 older child)
        final stageMomHope = deriveMotherStage(
          bornChildren: 1,
          hasActivePregnancy: false,
          tryingToConceive: true,
        );
        expect(stageMomHope, MotherStage.momHope);
        expect(stageMomHope.hasChildren, isTrue);
        expect(stageMomHope.tracksCycle, isTrue);
        expect(stageMomHope.effectiveStatus, UserStatus.hope);

        // 2. Mother in pregnancy (pregnant again, has 2 older children)
        final stagePregnantWithChildren = deriveMotherStage(
          bornChildren: 2,
          hasActivePregnancy: true,
          tryingToConceive: false,
        );
        expect(stagePregnantWithChildren, MotherStage.pregnantWithChildren);
        expect(stagePregnantWithChildren.hasChildren, isTrue);
        expect(stagePregnantWithChildren.isPregnant, isTrue);
        expect(stagePregnantWithChildren.effectiveStatus, UserStatus.pregnant);

        // 3. Mother in mom stage (has 3 children, not TTC, not pregnant)
        final stageMom = deriveMotherStage(
          bornChildren: 3,
          hasActivePregnancy: false,
          tryingToConceive: false,
        );
        expect(stageMom, MotherStage.mom);
        expect(stageMom.hasChildren, isTrue);
        expect(stageMom.effectiveStatus, UserStatus.mom);

        // Changing status between stages preserves child count and never resets children
        final updatedToHope = deriveMotherStage(
          bornChildren: 3,
          hasActivePregnancy: false,
          tryingToConceive: true,
        );
        expect(updatedToHope, MotherStage.momHope);
        expect(updatedToHope.hasChildren, isTrue);

        final updatedToPregnant = deriveMotherStage(
          bornChildren: 3,
          hasActivePregnancy: true,
          tryingToConceive: false,
        );
        expect(updatedToPregnant, MotherStage.pregnantWithChildren);
        expect(updatedToPregnant.hasChildren, isTrue);
      },
    );

    test(
      'Criterion 3: Child limits match accepted Free, Premium and VIP offers',
      () {
        final freePlan = SubscriptionPlan.allPlans.firstWhere(
          (p) => p.tier == SubscriptionTier.free,
        );
        // Status-independent child creation still respects the accepted plan limits.
        expect(freePlan.childLimit, 1);

        final premiumPlan = SubscriptionPlan.allPlans.firstWhere(
          (p) => p.tier == SubscriptionTier.premium,
        );
        expect(premiumPlan.childLimit, 2);

        final vipPlan = SubscriptionPlan.allPlans.firstWhere(
          (p) => p.tier == SubscriptionTier.vip,
        );
        expect(vipPlan.childLimit, -1);
      },
    );

    test(
      'Criterion 4: Capsules can be associated with MAM profile alone, a child, or multiple profiles',
      () {
        // 1. MAM alone (mother souvenir)
        expect(
          () => validateCapsuleSubjects(childIds: const [], withMother: true),
          returnsNormally,
        );
        final spaceMother = deriveCapsuleSpace(
          childIds: const [],
          withMother: true,
        );
        expect(spaceMother, CapsuleSpace.mother);

        // 2. Child alone
        expect(
          () => validateCapsuleSubjects(
            childIds: const ['child_1'],
            withMother: false,
          ),
          returnsNormally,
        );
        final spaceChild = deriveCapsuleSpace(
          childIds: const ['child_1'],
          withMother: false,
        );
        expect(spaceChild, CapsuleSpace.child);

        // 3. Multi-child capsule (siblings together)
        expect(
          () => validateCapsuleSubjects(
            childIds: const ['child_1', 'child_2'],
            withMother: false,
          ),
          returnsNormally,
        );
        final spaceFamilySiblings = deriveCapsuleSpace(
          childIds: const ['child_1', 'child_2'],
          withMother: false,
        );
        expect(spaceFamilySiblings, CapsuleSpace.family);

        // 4. Mother + Child (family memory)
        expect(
          () => validateCapsuleSubjects(
            childIds: const ['child_1'],
            withMother: true,
          ),
          returnsNormally,
        );
        final spaceFamilyMother = deriveCapsuleSpace(
          childIds: const ['child_1'],
          withMother: true,
        );
        expect(spaceFamilyMother, CapsuleSpace.family);

        // 5. Invalid capsule (no child and no mother) throws ArgumentError
        expect(
          () => validateCapsuleSubjects(childIds: const [], withMother: false),
          throwsArgumentError,
        );
      },
    );

    test(
      'Criterion 5: Child data is properly isolated across multiple children',
      () {
        final child1 = Child(
          id: 'child_1',
          name: 'Inès',
          birthDate: DateTime(2022, 5, 14),
          gender: ChildGender.girl,
          bloodType: 'A+',
          notes: 'Firstborn child',
        );

        final child2 = Child(
          id: 'child_2',
          name: 'Adam',
          birthDate: DateTime(2024, 8, 20),
          gender: ChildGender.boy,
          bloodType: 'O+',
          notes: 'Second child',
        );

        expect(child1.id, isNot(equals(child2.id)));
        expect(child1.name, 'Inès');
        expect(child2.name, 'Adam');
        expect(child1.gender, ChildGender.girl);
        expect(child2.gender, ChildGender.boy);

        // Verify Firestore serialization maintains isolation
        final map1 = child1.toFirestore();
        final map2 = child2.toFirestore();
        expect(map1['name'], 'Inès');
        expect(map2['name'], 'Adam');
        expect(map1['bloodType'], 'A+');
        expect(map2['bloodType'], 'O+');

        // Verify deserialization
        final restored1 = Child.fromFirestore(map1, 'child_1');
        final restored2 = Child.fromFirestore(map2, 'child_2');
        expect(restored1.name, 'Inès');
        expect(restored2.name, 'Adam');
      },
    );

    test(
      'Criterion 6: Deleting one child does not impact other children or MAM profile',
      () {
        final children = [
          Child(
            id: 'c1',
            name: 'Child 1',
            birthDate: DateTime(2021, 1, 1),
            gender: ChildGender.boy,
          ),
          Child(
            id: 'c2',
            name: 'Child 2',
            birthDate: DateTime(2023, 2, 2),
            gender: ChildGender.girl,
          ),
        ];

        // Simulate deletion of c1
        final remaining = children.where((c) => c.id != 'c1').toList();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'c2');
        expect(remaining.first.name, 'Child 2');

        // Mother stage remains mom as long as at least 1 born child exists
        final stageAfterDelete = deriveMotherStage(
          bornChildren: remaining.length,
          hasActivePregnancy: false,
          tryingToConceive: false,
        );
        expect(stageAfterDelete, MotherStage.mom);
        expect(stageAfterDelete.hasChildren, isTrue);
      },
    );
  });
}
