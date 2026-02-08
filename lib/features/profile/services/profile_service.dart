import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/profile_models.dart';

/// Service for managing user profile data in Firestore.
class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const String _usersCollection = 'users';
  static const String _childrenSubcollection = 'children';

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
}
