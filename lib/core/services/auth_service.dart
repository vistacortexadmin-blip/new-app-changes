import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Unified AuthUser model supporting both live Firebase and resilient Local Dev sessions
class AuthUser {
  final String uid;
  final String? email;
  String? displayName;
  final String? photoUrl;
  final bool isLocalDemo;

  AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isLocalDemo = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isLocalDemo': isLocalDemo,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        uid: json['uid'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isLocalDemo: json['isLocalDemo'] as bool? ?? false,
      );

  Future<void> updateDisplayName(String name) async {
    displayName = name;
    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        await fbUser.updateDisplayName(name);
      }
    } catch (e) {
      debugPrint('[AuthUser] Notice updating Firebase displayName: $e');
    }
    // Update local cached session if in local mode
    if (isLocalDemo) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vistacortex_local_session', jsonEncode(toJson()));
      } catch (_) {}
    }
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _init();
  }

  static const String _localSessionKey = 'vistacortex_local_session';
  final StreamController<AuthUser?> _authController = StreamController<AuthUser?>.broadcast();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AnalyticsService _analytics = AnalyticsService();

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  Stream<AuthUser?> get authStateChanges => _authController.stream;

  Future<void> _init() async {
    // 1. Check if Firebase has an active session
    try {
      FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
        if (fbUser != null) {
          _currentUser = AuthUser(
            uid: fbUser.uid,
            email: fbUser.email,
            displayName: fbUser.displayName,
            photoUrl: fbUser.photoURL,
            isLocalDemo: false,
          );
          _authController.add(_currentUser);
        } else {
          // If no Firebase user, check local session cache
          final localUser = await _getLocalSession();
          if (localUser != null) {
            _currentUser = localUser;
            _authController.add(_currentUser);
          } else {
            _currentUser = null;
            _authController.add(null);
          }
        }
      });
    } catch (e) {
      debugPrint('[Auth] Firebase authStateChanges notice: $e');
      final localUser = await _getLocalSession();
      _currentUser = localUser;
      _authController.add(_currentUser);
    }
  }

  Future<AuthUser?> _getLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStr = prefs.getString(_localSessionKey);
      if (sessionStr != null) {
        return AuthUser.fromJson(jsonDecode(sessionStr) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[Auth] Error reading local session: $e');
    }
    return null;
  }

  Future<AuthUser> createLocalSession(String email, {String? displayName, String? photoUrl}) async {
    final uid = 'dev_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final user = AuthUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isLocalDemo: true,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localSessionKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('[Auth] Error persisting local session: $e');
    }
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  bool isConfigurationNotFoundError(dynamic e) {
    final str = e.toString().toUpperCase();
    final msg = (e is FirebaseAuthException ? (e.message ?? '') : '').toUpperCase();
    final code = (e is FirebaseAuthException ? e.code : '').toLowerCase();
    return str.contains('CONFIGURATION_NOT_FOUND') ||
        msg.contains('CONFIGURATION_NOT_FOUND') ||
        str.contains('CONFIGURATION-NOT-FOUND') ||
        code == 'configuration-not-found' ||
        (code == 'unknown' && (str.contains('INTERNAL ERROR') || msg.contains('INTERNAL ERROR')));
  }

  /// Formats raw Firebase exceptions into friendly user messages
  String formatAuthError(dynamic error) {
    if (isConfigurationNotFoundError(error)) {
      return 'Firebase Authentication is not yet enabled in Firebase Console. Switched to Local Mode.';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please switch to Sign Up.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or tap "Forgot Password?".';
        case 'invalid-credential':
          return 'Incorrect email or password. Please verify and try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email. Please sign in instead.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'operation-not-allowed':
          return 'Email/Password sign-in is disabled in Firebase Console.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please wait a few moments and try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    final str = error.toString().replaceAll('Exception: ', '').replaceAll('PlatformException: ', '');
    if (str.contains('sign_in_failed') || str.contains('ApiException: 10')) {
      return 'Google Sign-In requires SHA-1 in Firebase Console. Please sign in with Email & Password.';
    }
    return str;
  }

  /// Google Sign-In Flow
  Future<AuthUser?> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[Auth] Google sign in cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final fbUser = userCredential.user;

      _currentUser = AuthUser(
        uid: fbUser?.uid ?? 'google_${googleUser.id}',
        email: fbUser?.email ?? googleUser.email,
        displayName: fbUser?.displayName ?? googleUser.displayName,
        photoUrl: fbUser?.photoURL ?? googleUser.photoUrl,
        isLocalDemo: false,
      );
      _authController.add(_currentUser);

      await _analytics.logLogin('google');
      return _currentUser;
    } catch (e) {
      debugPrint('[Auth] Error during Google Sign-In: $e');
      if (isConfigurationNotFoundError(e) && googleUser != null) {
        debugPrint('[Auth] CONFIGURATION_NOT_FOUND: Logging in via Local Dev fallback');
        final localUser = await createLocalSession(
          googleUser.email,
          displayName: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
        );
        return localUser;
      }
      rethrow;
    }
  }

  /// Email & Password Sign-In
  Future<AuthUser> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = userCredential.user;
      _currentUser = AuthUser(
        uid: fbUser?.uid ?? 'unknown',
        email: fbUser?.email ?? email,
        displayName: fbUser?.displayName,
        photoUrl: fbUser?.photoURL,
        isLocalDemo: false,
      );
      _authController.add(_currentUser);
      await _analytics.logLogin('email');
      return _currentUser!;
    } catch (e) {
      debugPrint('[Auth] Email Sign-In error: $e');
      if (isConfigurationNotFoundError(e)) {
        debugPrint('[Auth] CONFIGURATION_NOT_FOUND: Falling back to local dev session');
        final localUser = await createLocalSession(email.trim());
        return localUser;
      }
      rethrow;
    }
  }

  /// Email & Password Sign-Up
  Future<AuthUser> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = userCredential.user;
      _currentUser = AuthUser(
        uid: fbUser?.uid ?? 'unknown',
        email: fbUser?.email ?? email,
        displayName: fbUser?.displayName,
        photoUrl: fbUser?.photoURL,
        isLocalDemo: false,
      );
      _authController.add(_currentUser);
      await _analytics.logSignUp('email');
      return _currentUser!;
    } catch (e) {
      debugPrint('[Auth] Email Sign-Up error: $e');
      if (isConfigurationNotFoundError(e)) {
        debugPrint('[Auth] CONFIGURATION_NOT_FOUND: Falling back to local dev session');
        final localUser = await createLocalSession(email.trim());
        return localUser;
      }
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('[Auth] Firebase signout notice: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localSessionKey);
    } catch (_) {}

    _currentUser = null;
    _authController.add(null);
    await _analytics.logEvent('user_signed_out');
  }
}
