import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service handling Firebase Auth operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign up with email, password, and name
  Future<AuthResult> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Échec de la création du compte');
      }

      // Update display name
      await user.updateDisplayName(name.trim());

      // Create user profile in Firestore
      await _createUserProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
      );

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return AuthResult.failure('Une erreur est survenue');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Échec de la connexion');
      }

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      debugPrint('SignIn Error: $e');
      return AuthResult.failure('Une erreur est survenue');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResult.failure('Connexion annulée');
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return AuthResult.failure('Échec de la connexion Google');
      }

      // Check if this is a new user, create profile if so
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Utilisateur',
          email: user.email ?? '',
        );
      }

      return AuthResult.success(user);
    } catch (e) {
      debugPrint('Google SignIn Error: $e');
      final msg = e.toString();
      if (msg.contains('network_error') || msg.contains('NetworkException')) {
        return AuthResult.failure('Pas de connexion réseau');
      }
      if (msg.contains('sign_in_failed') || msg.contains('ApiException: 10')) {
        return AuthResult.failure(
          'Connexion Google échouée (SHA-1 non enregistré dans Firebase)',
        );
      }
      if (msg.contains('ApiException: 12')) {
        return AuthResult.failure(
          'Google Play Services non disponible sur cet appareil',
        );
      }
      return AuthResult.failure('Erreur de connexion Google: $msg');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Permanently delete the user account and all associated data.
  ///
  /// Google Play REQUIREMENT: Any app with account creation MUST provide
  /// in-app account deletion (Google Play Developer Program Policies 2023+).
  ///
  /// Deletion cascade:
  ///   1. Firestore sub-collections (children, capsules, etc.)
  ///   2. Root user document in /users/{uid}
  ///   3. Firebase Auth account (reauthentication required if session is old)
  Future<DeleteAccountResult> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return DeleteAccountResult.failure('لا يوجد حساب مسجل الدخول');
    }

    try {
      final uid = user.uid;

      // 1. Delete Firestore sub-collections
      await _deleteSubCollection(uid, 'children');
      await _deleteSubCollection(uid, 'capsules');
      await _deleteSubCollection(uid, 'notifications');

      // 2. Delete main user document
      await _firestore.collection('users').doc(uid).delete();

      // 3. Sign out from Google provider
      await _googleSignIn.signOut();

      // 4. Delete Firebase Auth account
      await user.delete();

      return DeleteAccountResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return DeleteAccountResult.failure(
          'لأسباب أمنية، يجب تسجيل الدخول مجدداً قبل حذف الحساب. '
          'يُرجى الخروج وتسجيل الدخول ثم المحاولة مرة أخرى.',
          requiresReauth: true,
        );
      }
      return DeleteAccountResult.failure(
        'حدث خطأ أثناء حذف الحساب: ${e.message}',
      );
    } catch (e) {
      debugPrint('DeleteAccount Error: $e');
      return DeleteAccountResult.failure('حدث خطأ غير متوقع أثناء حذف الحساب');
    }
  }

  /// Helper: deletes all documents in a sub-collection for a given user.
  Future<void> _deleteSubCollection(String uid, String collection) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .limit(100)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Recurse if there were more documents
      if (snapshot.docs.length == 100) {
        await _deleteSubCollection(uid, collection);
      }
    } catch (e) {
      debugPrint('DeleteSubCollection($collection) Error: $e');
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e.code));
    } catch (e) {
      debugPrint('ResetPassword Error: $e');
      return AuthResult.failure('Une erreur est survenue lors de l\'envoi du lien');
    }
  }

  /// Map Firebase Auth error codes to French messages
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé';
      case 'invalid-email':
        return 'E-mail invalide';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet e-mail';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'network-request-failed':
        return 'Erreur de connexion réseau';
      default:
        return 'Une erreur est survenue ($code)';
    }
  }
}

/// Result wrapper for auth operations
class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool isSuccess;

  AuthResult._({this.user, this.errorMessage, required this.isSuccess});

  factory AuthResult.success([User? user]) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(errorMessage: message, isSuccess: false);
  }
}

/// Result wrapper for account deletion.
class DeleteAccountResult {
  final bool isSuccess;
  final String? errorMessage;
  /// True when Firebase requires the user to re-authenticate before deletion.
  final bool requiresReauth;

  DeleteAccountResult._({
    required this.isSuccess,
    this.errorMessage,
    this.requiresReauth = false,
  });

  factory DeleteAccountResult.success() {
    return DeleteAccountResult._(isSuccess: true);
  }

  factory DeleteAccountResult.failure(
    String message, {
    bool requiresReauth = false,
  }) {
    return DeleteAccountResult._(
      isSuccess: false,
      errorMessage: message,
      requiresReauth: requiresReauth,
    );
  }
}
