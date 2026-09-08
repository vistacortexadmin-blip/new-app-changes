import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AnalyticsService _analytics = AnalyticsService();

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

      // 5. Track Analytics
      await _analytics.logLogin('google');
      await _analytics.logEvent('google_sign_in_success', {
        'user_id': userCredential.user?.uid ?? '',
        'email': userCredential.user?.email ?? '',
      });

      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Error during Google Sign-In: $e');
      await _analytics.logEvent('google_sign_in_failed', {
        'error': e.toString(),
      });
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
      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Email Sign-In error: $e');
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
      return userCredential;
    } catch (e) {
      debugPrint('[Auth] Email Sign-Up error: $e');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      await _analytics.logEvent('user_signed_out');
    } catch (e) {
      debugPrint('[Auth] Sign out notice: $e');
    }
  }
}
