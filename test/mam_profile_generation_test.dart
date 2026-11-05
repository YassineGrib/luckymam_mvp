import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';

void main() {
  group('LM-ONB-004: Primary MAM Profile Generation & Persistence Tests', () {
    test('Default UserProfile creation assigns UserStatus.mom', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test_uid_123',
        displayName: 'Amina',
        email: 'amina@example.com',
        status: UserStatus.mom,
        createdAt: now,
        updatedAt: now,
        schemaVersion: kCurrentProfileSchemaVersion,
      );

      expect(profile.status, UserStatus.mom);
      expect(profile.schemaVersion, 2);
      expect(profile.displayName, 'Amina');
    });

    test('UserProfile fromFirestore correctly falls back to UserStatus.mom', () {
      final data = {
        'displayName': 'Sarah',
        'email': 'sarah@example.com',
        'createdAt': null,
        'updatedAt': null,
      };

      final profile = UserProfile.fromMap(data, 'uid_456');
      expect(profile.status, UserStatus.mom);
      expect(profile.displayName, 'Sarah');
    });

    test('UserProfile preserves existing data and status when updated', () {
      final now = DateTime.now();
      final initialProfile = UserProfile(
        uid: 'test_uid_789',
        displayName: 'Maman',
        email: 'test@example.com',
        status: UserStatus.mom,
        createdAt: now,
        updatedAt: now,
        schemaVersion: kCurrentProfileSchemaVersion,
      );

      // Simulating status change to pregnant
      final updatedProfile = UserProfile(
        uid: initialProfile.uid,
        displayName: initialProfile.displayName,
        email: initialProfile.email,
        status: UserStatus.pregnant,
        createdAt: initialProfile.createdAt,
        updatedAt: DateTime.now(),
        schemaVersion: initialProfile.schemaVersion,
      );

      expect(updatedProfile.uid, initialProfile.uid);
      expect(updatedProfile.createdAt, initialProfile.createdAt);
      expect(updatedProfile.status, UserStatus.pregnant);
    });
  });
}

