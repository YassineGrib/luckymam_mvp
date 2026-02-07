import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication service handling Firebase Auth operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
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

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(errorMessage: message, isSuccess: false);
  }
}
