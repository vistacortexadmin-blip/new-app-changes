import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/reminders/models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ');
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyMedicineReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required DoseTimeOfDay timeOfDay,
    required String timeString,
  }) async {
    final parts = timeString.split(' ');
    if (parts.length != 2) return;
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return;

    int hour;
    int minute;
    try {
      hour = int.parse(timeParts[0]);
      minute = int.parse(timeParts[1]);
    } catch (_) {
      return; // Invalid time format
    }
    
    final isPM = parts[1].toUpperCase() == 'PM';
    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime doseTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (doseTime.isBefore(now)) {
      doseTime = doseTime.add(const Duration(days: 1));
    }
    
    tz.TZDateTime scheduledDate = doseTime.subtract(const Duration(minutes: 5));
    
    // FIX FOR B3: If the 5-min pre-alert is in the past, DO NOT schedule for 5 secs from now
    // because it's a repeating alarm. Instead, just push it to tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_channel_id',
      'Medicine Reminders',
      channelDescription: 'Daily reminders to take your medicine',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.secret, // FIX FOR H5: Hide from lock screen if device is locked
    );

    // FIX FOR H5: Neutral notification bodies to protect privacy
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time for your medicine',
      'It is time to take your scheduled dose.',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medicine_',
    );
  }

  Future<void> scheduleTestReminder({
    required int id,
    required String testName,
    required String labName,
    required DateTime date,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final testDay8am = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day, 8, 0),
      tz.local,
    );

    if (testDay8am.isBefore(now) && 
        DateTime(date.year, date.month, date.day).isBefore(DateTime(now.year, now.month, now.day))) {
      return;
    }

    tz.TZDateTime scheduledDate = testDay8am.subtract(const Duration(days: 3));
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = testDay8am.subtract(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = testDay8am;
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = now.add(const Duration(seconds: 5)); // One-off is fine for 5 secs
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel_id',
      'Diagnostic Tests',
      channelDescription: 'Reminders for upcoming diagnostic tests',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.secret, // FIX FOR H5
    );

    // FIX FOR H5: Neutral notification bodies
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Upcoming Diagnostic Test',
      'You have a scheduled test coming up.',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showRefillWarning({
    required int id,
    required String medicineName,
    required int daysLeft,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'refill_channel_id',
      'Refill Alerts',
      channelDescription: 'Alerts when your medicine stock is running low',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.secret, // FIX FOR H5
    );

    // FIX FOR H5: Neutral notification bodies
    await flutterLocalNotificationsPlugin.show(
      id,
      'Low Stock Alert',
      'One of your medications is running low on stock.',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
