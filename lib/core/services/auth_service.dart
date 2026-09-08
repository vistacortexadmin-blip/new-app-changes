import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../security/security_audit_model.dart';
import '../security/security_audit_service.dart';
import 'analytics_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AnalyticsService _analytics = AnalyticsService();
  final SecurityAuditService _audit = SecurityAuditService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google Sign-In Flow
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign In UI flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in dialog
        debugPrint('[Auth] Google sign in cancelled by user');
        return null;
      }

      // 2. Obtain authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 5. Track Analytics & Security Audit
      await _analytics.logLogin('google');
      await _audit.record(
        actionType: AuditActionType.authLoginSuccess,
        resourceType: AuditResourceType.authSession,
        resourceId: userCredential.user?.uid ?? 'unknown',
        dataClassification: DataClassification.security,
        actorId: userCredential.user?.uid ?? 'unknown',
        actorEmail: userCredential.user?.email ?? '',
        metadata: {'authMethod': 'google_oauth'},
      );

      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Error during Google Sign-In: $e');
      await _audit.record(
        actionType: AuditActionType.authLoginFailure,
        resourceType: AuditResourceType.authSession,
        resourceId: 'failed_auth',
        dataClassification: DataClassification.security,
        outcome: AuditOutcome.failure,
        failureReason: e.toString(),
        metadata: {'authMethod': 'google_oauth'},
      );
      rethrow;
    }
  }

  /// Email & Password Sign-In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _analytics.logLogin('email');
      await _audit.record(
        actionType: AuditActionType.authLoginSuccess,
        resourceType: AuditResourceType.authSession,
        resourceId: userCredential.user?.uid ?? 'unknown',
        dataClassification: DataClassification.security,
        actorId: userCredential.user?.uid ?? 'unknown',
        actorEmail: userCredential.user?.email ?? email,
        metadata: {'authMethod': 'email_password'},
      );
      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Email Sign-In error: $e');
      await _audit.record(
        actionType: AuditActionType.authLoginFailure,
        resourceType: AuditResourceType.authSession,
        resourceId: 'failed_email_auth',
        dataClassification: DataClassification.security,
        outcome: AuditOutcome.failure,
        failureReason: e.toString(),
        metadata: {'attemptedEmail': email},
      );
      rethrow;
    }
  }

  /// Email & Password Sign-Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _analytics.logSignUp('email');
      await _audit.record(
        actionType: AuditActionType.authLoginSuccess,
        resourceType: AuditResourceType.authSession,
        resourceId: userCredential.user?.uid ?? 'unknown',
        dataClassification: DataClassification.security,
        actorId: userCredential.user?.uid ?? 'unknown',
        actorEmail: userCredential.user?.email ?? email,
        metadata: {'authMethod': 'email_signup'},
      );
      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Email Sign-Up error: $e');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      final uid = currentUser?.uid ?? 'current_user';
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      await _analytics.logEvent('user_signed_out');
      await _audit.record(
        actionType: AuditActionType.authLogout,
        resourceType: AuditResourceType.authSession,
        resourceId: uid,
        dataClassification: DataClassification.security,
        actorId: uid,
        metadata: {'action': 'user_explicit_logout'},
      );
    } catch (e) {
      debugPrint('[Auth] Sign out notice: $e');
    }
  }
}
