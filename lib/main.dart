import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FIX FOR M2: Turn on App Check to secure backend resources
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase initialization notice: $e');
  }

  // Initialize and request notification permissions
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
  } catch (e) {
    if (kDebugMode) debugPrint('Notification initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: VistaCortexApp(),
    ),
  );
}

