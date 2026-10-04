import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/reminders/models/reminder.dart';

const supabaseUrl = 'https://qfvakepnvvvookhewqoc.supabase.co';
const supabaseAnonKey = 'sb_publishable_zcv4CkzOP3cJBz2n2S5udg_5p9O8Fvg';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>('reminders');
  // ignore: avoid_print
  print('>>> Hive ready');

  // Supabase
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  // ignore: avoid_print
  print('>>> Supabase ready');

  // Notifications
  await NotificationService.instance.init();
  // ignore: avoid_print
  print('>>> Notifications ready');

  runApp(const ProviderScope(child: VistaCortexApp()));
}
