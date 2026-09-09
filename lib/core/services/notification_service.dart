import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/reminders/models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final localOffset = DateTime.now().timeZoneOffset;
    final allLocations = tz.timeZoneDatabase.locations;
    tz.Location? matchedLocation;
    for (final entry in allLocations.entries) {
      final loc = entry.value;
      if (loc.zones.isNotEmpty) {
        final zone = loc.currentTimeZone;
        if (zone.offset == localOffset.inMilliseconds) {
          matchedLocation = loc;
          break;
        }
      }
    }
    tz.setLocalLocation(matchedLocation ?? tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_now_channel',
      'Instant Test',
      channelDescription: 'Immediate test notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    await flutterLocalNotificationsPlugin.show(
      9999,
      'Notifications are working!',
      'VistaCortex will remind you to take your medicines on time.',
      const NotificationDetails(android: androidDetails),
    );
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
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    final isPM = parts[1].toUpperCase() == 'PM';
    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_channel_id',
      'Medicine Reminders',
      channelDescription: 'Daily reminders to take your medicine',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medicine Reminder',
      'Time to take $medicineName ($dosage)',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medicine_$id',
    );
  }

  Future<void> scheduleTestReminder({
    required int id,
    required String testName,
    required String labName,
    required DateTime date,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day, 8, 0),
      tz.local,
    );
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel_id',
      'Diagnostic Tests',
      channelDescription: 'Reminders for upcoming diagnostic tests',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Upcoming Test Today',
      'You have a $testName at $labName today. Stay prepared!',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showRefillWarning({
    required int id,
    required String medicineName,
    required int daysLeft,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'refill_channel_id',
      'Refill Warnings',
      channelDescription: 'Alerts when medicine stock is running low',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      'Low Stock Alert',
      'Only $daysLeft days of $medicineName remaining. Order a refill!',
      const NotificationDetails(android: androidDetails),
    );
  }

  void cancelNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id);
  }
}
