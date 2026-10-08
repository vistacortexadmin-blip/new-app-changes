import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
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

  // Some Android devices report legacy timezone IDs that the tz package doesn't have
  static const _legacyTimezoneMap = {
    'Asia/Calcutta': 'Asia/Kolkata',
    'US/Eastern': 'America/New_York',
    'US/Central': 'America/Chicago',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();
    // FIX FOR L5: Read the actual local timezone from the device instead of relying on UTC offsets
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      String tzId = timeZoneInfo.identifier;
      // Map legacy IDs to modern IANA names
      tzId = _legacyTimezoneMap[tzId] ?? tzId;
      tz.setLocalLocation(tz.getLocation(tzId));
      if (kDebugMode) debugPrint('[NotificationService] Timezone set to: $tzId');
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationService] Failed to set timezone: $e, falling back to UTC');
      // Fallback: use device UTC offset to approximate
      try {
        final now = DateTime.now();
        final offset = now.timeZoneOffset;
        // Search for a location matching the offset
        tz.setLocalLocation(tz.getLocation('Etc/UTC'));
      } catch (_) {}
    }

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
        if (kDebugMode) debugPrint('Notification clicked: ');
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
    
    if (kDebugMode) debugPrint('[NotificationService] Scheduling: now=$now, doseTime=$doseTime, timeString=$timeString');

    if (doseTime.isBefore(now)) {
      // Fix DST: use constructor instead of Duration(days: 1)
      doseTime = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, hour, minute);
    }
    
    tz.TZDateTime scheduledDate = doseTime.subtract(const Duration(minutes: 5));
    
    if (scheduledDate.isBefore(now)) {
      // Fix DST: use constructor instead of Duration(days: 1)
      scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month, scheduledDate.day + 1, scheduledDate.hour, scheduledDate.minute);
    }

    if (kDebugMode) debugPrint('[NotificationService] Final scheduledDate=$scheduledDate for id=$id');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_channel_id',
      'Medicine Reminders',
      channelDescription: 'Daily reminders to take your medicine',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.private, // FIX FOR H5: Private shows notification but hides payload on lock screen
    );

    // FIX FOR H5: Neutral notification bodies to protect privacy
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time for your medicine',
      'It is time to take your scheduled dose.',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Use exact for medicines
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime, // Fix for travel/DST
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
    final testDay8am = tz.TZDateTime(
      tz.local,
      date.year, 
      date.month, 
      date.day, 
      8, 
      0
    );

    if (testDay8am.isBefore(now) && 
        DateTime(date.year, date.month, date.day).isBefore(DateTime(now.year, now.month, now.day))) {
      return;
    }

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, testDay8am.year, testDay8am.month, testDay8am.day - 3, 8, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, testDay8am.year, testDay8am.month, testDay8am.day - 1, 8, 0);
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
      visibility: NotificationVisibility.private, // FIX FOR H5
    );

    // FIX FOR H5: Neutral notification bodies
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Upcoming Diagnostic Test',
      'You have a scheduled test coming up.',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
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
