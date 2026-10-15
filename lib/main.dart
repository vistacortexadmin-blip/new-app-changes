import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/reminders/models/reminder.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('>>> Firebase ready');
  } catch (e, st) {
    print('>>> Firebase FAILED: $e');
    print('>>> $st');
  }

  // Initialize Hive.
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(ReminderAdapter().typeId)) {
    Hive.registerAdapter(ReminderAdapter());
  }

  await Hive.openBox<Reminder>('reminders');
  print('>>> Hive ready');

  // Initialize local notifications before the app starts.
  try {
    debugPrint('[NOTIFY-TEST] Starting immediate notification test');

    await NotificationService.instance.showSystemNotification(
      id: 'vistacortex-diagnostic-001',
      title: 'VistaCortex test',
      body: 'If you see this, notifications are working.',
      showDetailsOnLockScreen: true,
    );

    debugPrint('[NOTIFY-TEST] show() completed successfully');
  } catch (error, stackTrace) {
    debugPrint('[NOTIFY-TEST] FAILED: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  runApp(
    const ProviderScope(
      child: VistaCortexApp(),
    ),
  );
}
