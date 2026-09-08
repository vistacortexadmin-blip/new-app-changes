import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  FirebaseAnalytics get _firebaseAnalytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  /// Log custom screen view
  Future<void> logScreen(String screenName) async {
    try {
      await _firebaseAnalytics.logScreenView(screenName: screenName);
      debugPrint('[Analytics] Screen viewed: $screenName');
    } catch (e) {
      debugPrint('[Analytics] logScreen notice: $e');
    }
  }

  /// Log login event with method (e.g. 'google', 'email')
  Future<void> logLogin(String method) async {
    try {
      await _firebaseAnalytics.logLogin(loginMethod: method);
      debugPrint('[Analytics] User logged in via: $method');
    } catch (e) {
      debugPrint('[Analytics] logLogin notice: $e');
    }
  }

  /// Log sign up event
  Future<void> logSignUp(String method) async {
    try {
      await _firebaseAnalytics.logSignUp(signUpMethod: method);
      debugPrint('[Analytics] User signed up via: $method');
    } catch (e) {
      debugPrint('[Analytics] logSignUp notice: $e');
    }
  }

  /// Log custom event with parameters
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('[Analytics] Event logged: $name with params: $parameters');
    } catch (e) {
      debugPrint('[Analytics] logEvent notice: $e');
    }
  }
}
