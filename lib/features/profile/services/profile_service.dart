import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/mother_stage.dart';
import '../models/pregnancy.dart';
import '../models/profile_models.dart';
import 'profile_migration.dart';

/// Service for managing user profile data in Firestore.
class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const String _usersCollection = 'users';
  static const String _childrenSubcollection = 'children';
  static const String _pregnanciesSubcollection = 'pregnancies';

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Get current user's UID.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Reference to current user's document.
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection(_usersCollection).doc(uid);
  }

  /// Reference to children subcollection.
  CollectionReference<Map<String, dynamic>>? get _childrenCollection {
    return _userDoc?.collection(_childrenSubcollection);
  }

  // ============ PREGNANCY OPERATIONS ============

  /// Reference to pregnancies subcollection.
  CollectionReference<Map<String, dynamic>>? get _pregnanciesCollection {
    return _userDoc?.collection(_pregnanciesSubcollection);
  }

  // ============ PROFILE OPERATIONS ============

  /// Get user profile stream.
  Stream<UserProfile?> watchProfile() {
    final doc = _userDoc;
    if (doc == null) return Stream.value(null);

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  /// Get user profile once.
  Future<UserProfile?> getProfile() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;
    return UserProfile.fromFirestore(snapshot);
  }

  /// Create or update user profile.
  Future<void> saveProfile(UserProfile profile) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('User not authenticated');

    await doc.set(profile.toFirestore(), SetOptions(merge: true));
  }

  /// Update specific profile fields.
  Future<void> updateProfileFields(Map<String, dynamic> fields) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('User not authenticated');

    fields['updatedAt'] = FieldValue.serverTimestamp();
    await doc.update(fields);
  }

  /// Create initial profile for new user.
  Future<void> createInitialProfile({
    required String displayName,
    required String email,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final profile = UserProfile(
      uid: uid,
      displayName: displayName,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveProfile(profile);
  }

  // ============ CHILDREN OPERATIONS ============

  /// Watch children list.
  Stream<List<Child>> watchChildren() {
    final collection = _childrenCollection;
    if (collection == null) return Stream.value([]);

    return collection.orderBy('birthDate', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Child.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get children list once.
  Future<List<Child>> getChildren() async {
    final collection = _childrenCollection;
    if (collection == null) return [];

    final snapshot = await collection
        .orderBy('birthDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Child.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Add a new child.
  Future<String> addChild(Child child) async {
    final collection = _childrenCollection;
    if (collection == null) throw Exception('User not authenticated');

    final docRef = await collection.add(child.toFirestore());
    return docRef.id;
  }

  /// Update a child.
  Future<void> updateChild(Child child) async {
    final collection = _childrenCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(child.id).update(child.toFirestore());
  }

  /// Delete a child.
  Future<void> deleteChild(String childId) async {
    final collection = _childrenCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(childId).delete();
  }

  /// Upload child photo to Firebase Storage.
  Future<String> uploadChildPhoto(String childId, File file) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final path = 'users/$uid/children/$childId/photo.jpg';
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload user profile photo to Firebase Storage.
  Future<String> uploadUserProfilePhoto(File file) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final path = 'users/$uid/profile/photo.jpg';
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ============ MEDICAL INFO OPERATIONS ============

  /// Update medical information.
  Future<void> updateMedicalInfo(MedicalInfo medicalInfo) async {
    await updateProfileFields({'medicalInfo': medicalInfo.toFirestore()});
  }

  // ============ CYCLE INFO OPERATIONS ============

  /// Update cycle information.
  Future<void> updateCycleInfo(CycleInfo cycleInfo) async {
    await updateProfileFields({'cycleInfo': cycleInfo.toFirestore()});
  }

  /// Log period start date.
  Future<void> logPeriodStart(DateTime date) async {
    final profile = await getProfile();
    if (profile == null) return;

    final updatedCycle = profile.cycleInfo.copyWith(
      lastPeriodDate: date,
      isTracking: true,
    );

    await updateCycleInfo(updatedCycle);
  }

  /// Save DDR (date des dernières règles) for pregnancy tracking.
  Future<void> savePregnancyLmp(DateTime lmpDate) async {
    final profile = await getProfile();
    if (profile == null) return;

    final updatedCycle = profile.cycleInfo.copyWith(
      lastPeriodDate: lmpDate,
      isTracking: true,
    );
    await updateCycleInfo(updatedCycle);
  }

  // ============ STATUS OPERATIONS ============

  /// Update user status (pregnant/mom).
  Future<void> updateStatus(
    UserStatus status, {
    DateTime? pregnancyDate,
  }) async {
    final fields = <String, dynamic>{'status': status.name};

    if (pregnancyDate != null) {
      fields['lastPregnancyDate'] = Timestamp.fromDate(pregnancyDate);
    }

    await updateProfileFields(fields);
  }

  // ============ PERSONAL INFO OPERATIONS ============

  /// Update personal information.
  Future<void> updatePersonalInfo({
    String? displayName,
    String? phone,
    DateTime? birthDate,
    String? wilaya,
    String? photoUrl,
  }) async {
    final fields = <String, dynamic>{};

    if (displayName != null) fields['displayName'] = displayName;
    if (phone != null) fields['phone'] = phone;
    if (birthDate != null) fields['birthDate'] = Timestamp.fromDate(birthDate);
    if (wilaya != null) fields['wilaya'] = wilaya;
    if (photoUrl != null) fields['photoUrl'] = photoUrl;

    if (fields.isNotEmpty) {
      await updateProfileFields(fields);
    }
  }

  /// Comprehensive atomic update for mother's profile.
  Future<void> updateFullProfile({
    String? displayName,
    String? phone,
    DateTime? birthDate,
    String? wilaya,
    String? photoUrl,
    bool removePhoto = false,
    UserStatus? status,
    DateTime? pregnancyDate,
    MedicalInfo? medicalInfo,
  }) async {
    final fields = <String, dynamic>{};

    if (displayName != null) fields['displayName'] = displayName;
    if (phone != null) fields['phone'] = phone;
    if (birthDate != null) fields['birthDate'] = Timestamp.fromDate(birthDate);
    if (wilaya != null) fields['wilaya'] = wilaya;
    if (photoUrl != null) fields['photoUrl'] = photoUrl;
    if (removePhoto) fields['photoUrl'] = FieldValue.delete();
    if (status != null) fields['status'] = status.name;
    if (pregnancyDate != null) {
      fields['lastPregnancyDate'] = Timestamp.fromDate(pregnancyDate);
    }
    if (medicalInfo != null) {
      fields['medicalInfo'] = medicalInfo.toFirestore();
    }

    if (fields.isNotEmpty) {
      await updateProfileFields(fields);
    }
  }

  // ============ PREGNANCY & MOTHER JOURNEY OPERATIONS ============

  /// Watch pregnancies list ordered by creation date descending.
  Stream<List<Pregnancy>> watchPregnancies() {
    final collection = _pregnanciesCollection;
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Pregnancy.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get pregnancies list once ordered by creation date descending.
  Future<List<Pregnancy>> getPregnancies() async {
    final collection = _pregnanciesCollection;
    if (collection == null) return [];

    final snapshot = await collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Pregnancy.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Private helper that reads children, pregnancies, and profile once,
  /// recomputes the derived [MotherStage], and writes the legacy status field.
  Future<void> _writeDerivedStatus() async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final children = await getChildren();
    final pregnancies = await getPregnancies();
    final profile = await getProfile();

    final bornCount = children.where((c) => c.isBorn && !c.archived).length;
    final hasActive = pregnancies.any((p) => p.isActive);
    final ttc = profile?.tryingToConceive ?? false;

    final stage = deriveMotherStage(
      bornChildren: bornCount,
      hasActivePregnancy: hasActive,
      tryingToConceive: ttc,
    );

    await updateProfileFields({'status': stage.legacyStatus.name});
  }

  /// Declares a new pregnancy and creates [babyCount] expected child folders.
  /// Executes pregnancy doc creation, child doc(s) creation, and user doc updates
  /// in a single [WriteBatch]. Returns the created pregnancy ID.
  Future<String> declarePregnancy({
    required DateTime lmpDate,
    DateTime? eddDate,
    EddSource eddSource = EddSource.lmp,
    int babyCount = 1,
    required String placeholderName,
  }) async {
    final userDoc = _userDoc;
    final pregCol = _pregnanciesCollection;
    final childCol = _childrenCollection;
    if (currentUserId == null ||
        userDoc == null ||
        pregCol == null ||
        childCol == null) {
      throw Exception('User not authenticated');
    }

    final edd = eddDate ?? Pregnancy.eddFromLmp(lmpDate);
    final now = DateTime.now();

    final pregnancyRef = pregCol.doc();
    final childRefs = List.generate(babyCount, (_) => childCol.doc());
    final childIds = childRefs.map((r) => r.id).toList();

    final pregnancy = Pregnancy(
      id: pregnancyRef.id,
      lmpDate: lmpDate,
      eddDate: edd,
      eddSource: eddSource,
      babyCount: babyCount,
      childIds: childIds,
      status: PregnancyStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();
    batch.set(pregnancyRef, pregnancy.toFirestore());

    for (var i = 0; i < babyCount; i++) {
      final name =
          babyCount == 1 ? placeholderName : '$placeholderName ${i + 1}';
      final child = Child(
        id: childIds[i],
        name: name,
        birthDate: edd,
        gender: ChildGender.unknown,
        lifecycle: ChildLifecycle.expected,
        expectedDate: edd,
        pregnancyId: pregnancyRef.id,
        archived: false,
      );
      batch.set(childRefs[i], child.toFirestore());
    }

    batch.update(userDoc, {
      'status': UserStatus.pregnant.name,
      'tryingToConceive': false,
      'lastPregnancyDate': Timestamp.fromDate(lmpDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    await _writeDerivedStatus();
    return pregnancyRef.id;
  }

  /// Converts an expected child to born status with their actual birth details.
  /// If every child linked to that pregnancy is born, marks the pregnancy delivered.
  /// Recomputes and writes the derived user status.
  Future<void> markChildBorn({
    required String childId,
    required DateTime birthDate,
    required String name,
    required ChildGender gender,
  }) async {
    final childCol = _childrenCollection;
    if (childCol == null) throw Exception('User not authenticated');

    final childDoc = await childCol.doc(childId).get();
    if (!childDoc.exists) throw Exception('Child not found');

    final child = Child.fromFirestore(childDoc.data()!, childId);

    await childCol.doc(childId).update({
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender.name,
      'lifecycle': ChildLifecycle.born.name,
      'expectedDate': FieldValue.delete(),
    });

    final pregnancyId = child.pregnancyId;
    final pregCol = _pregnanciesCollection;
    if (pregnancyId != null && pregCol != null) {
      final pregDoc = await pregCol.doc(pregnancyId).get();
      if (pregDoc.exists) {
        final preg = Pregnancy.fromFirestore(pregDoc.data()!, pregDoc.id);
        final allChildren = await getChildren();
        final allBorn = preg.childIds.every((id) {
          if (id == childId) return true;
          final match = allChildren.where((c) => c.id == id).firstOrNull;
          return match != null && match.isBorn;
        });

        if (allBorn) {
          await pregCol.doc(pregnancyId).update({
            'status': PregnancyStatus.delivered.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }
    }

    await _writeDerivedStatus();
  }

  /// Ends an active pregnancy.
  /// If [keepMemories] is true, expected child docs are kept with `archived: true`.
  /// If false, expected child docs are deleted.
  /// Recomputes and writes the derived user status.
  Future<void> endPregnancy(
    String pregnancyId, {
    required bool keepMemories,
  }) async {
    final pregCol = _pregnanciesCollection;
    final childCol = _childrenCollection;
    if (pregCol == null || childCol == null) {
      throw Exception('User not authenticated');
    }

    final pregDoc = await pregCol.doc(pregnancyId).get();
    if (!pregDoc.exists) throw Exception('Pregnancy not found');

    final preg = Pregnancy.fromFirestore(pregDoc.data()!, pregDoc.id);
    final now = DateTime.now();

    final batch = _firestore.batch();
    batch.update(pregCol.doc(pregnancyId), {
      'status': PregnancyStatus.ended.name,
      'endedAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    for (final childId in preg.childIds) {
      final childDoc = await childCol.doc(childId).get();
      if (childDoc.exists) {
        final child = Child.fromFirestore(childDoc.data()!, childId);
        if (child.isExpected) {
          if (keepMemories) {
            batch.update(childCol.doc(childId), {'archived': true});
          } else {
            batch.delete(childCol.doc(childId));
          }
        }
      }
    }

    await batch.commit();
    await _writeDerivedStatus();
  }

  /// Sets whether the mother is actively trying to conceive,
  /// and updates the derived legacy status.
  Future<void> setTryingToConceive(bool value) async {
    await updateProfileFields({'tryingToConceive': value});
    await _writeDerivedStatus();
  }

  /// Runs profile schema migration to version 2 if required.
  /// If [needsMigration] is true, applies the migration plan in a single batch
  /// (creating pregnancy and expected child if pregnant with LMP, or setting TTC if hope)
  /// and updates [schemaVersion] to 2 so future runs are no-ops.
  Future<void> runProfileMigrationIfNeeded({
    required String placeholderName,
  }) async {
    final profile = await getProfile();
    if (profile == null) return;
    if (!needsMigration(profile)) return;

    final userDoc = _userDoc;
    final pregCol = _pregnanciesCollection;
    final childCol = _childrenCollection;
    if (userDoc == null || pregCol == null || childCol == null) {
      throw Exception('User not authenticated');
    }

    final plan = buildProfileMigration(profile);
    final batch = _firestore.batch();
    final userUpdates = <String, dynamic>{
      'schemaVersion': kCurrentProfileSchemaVersion,
      'tryingToConceive': plan.setTryingToConceive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (plan.createPregnancy) {
      final lmp = plan.lmp!;
      final edd = Pregnancy.eddFromLmp(lmp);
      final now = DateTime.now();
      final pregnancyRef = pregCol.doc();
      final childRef = childCol.doc();

      final pregnancy = Pregnancy(
        id: pregnancyRef.id,
        lmpDate: lmp,
        eddDate: edd,
        eddSource: EddSource.lmp,
        babyCount: 1,
        childIds: [childRef.id],
        status: PregnancyStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(pregnancyRef, pregnancy.toFirestore());

      final child = Child(
        id: childRef.id,
        name: placeholderName,
        birthDate: edd,
        gender: ChildGender.unknown,
        lifecycle: ChildLifecycle.expected,
        expectedDate: edd,
        pregnancyId: pregnancyRef.id,
        archived: false,
      );
      batch.set(childRef, child.toFirestore());

      userUpdates['status'] = UserStatus.pregnant.name;
    } else if (plan.setTryingToConceive) {
      userUpdates['status'] = UserStatus.hope.name;
    }

    batch.update(userDoc, userUpdates);
    await batch.commit();
  }
}
