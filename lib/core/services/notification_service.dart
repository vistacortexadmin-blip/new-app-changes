import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';
import '../../features/reminders/models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Dedicated medical notification channel with USAGE_ALARM to bypass DND & silent mode
  static const String medicineChannelId = 'medical_emergency_channel_v2';
  static const String medicineChannelName = 'Medical Emergency Alerts';
  static const String medicineChannelDesc =
      'Critical medical alerts and medicine reminders that bypass Do Not Disturb';

  static final AndroidNotificationChannel medicineChannel =
      AndroidNotificationChannel(
    medicineChannelId,
    medicineChannelName,
    description: medicineChannelDesc,
    importance: Importance.max,
    playSound: true,
    sound: const RawResourceAndroidNotificationSound('alarm_loud'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    audioAttributesUsage: AudioAttributesUsage.alarm, // Bypasses standard DND & mute switch
  );

  // Method channel for native Android DND settings & permission inspection
  static const MethodChannel _dndChannel =
      MethodChannel('com.vistacortex/dnd_settings');

  /// Opens Android system settings directly to the medical notification channel,
  /// allowing the user to toggle "Override Do Not Disturb" / "Bypass Do Not Disturb".
  Future<bool> openChannelDndSettings(
      {String channelId = medicineChannelId}) async {
    try {
      final res = await _dndChannel
          .invokeMethod<bool>('openChannelNotificationSettings', {
        'channelId': channelId,
      });
      return res ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Error opening channel DND settings: $e');
      }
      return false;
    }
  }

  /// Checks if the app has been granted system Do Not Disturb (Notification Policy) access.
  Future<bool> isNotificationPolicyAccessGranted() async {
    try {
      final res = await _dndChannel
          .invokeMethod<bool>('isNotificationPolicyAccessGranted');
      return res ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Error checking DND policy access: $e');
      }
      return false;
    }
  }

  /// Opens Android system "Do Not Disturb access" settings so the user can grant policy access.
  Future<bool> openNotificationPolicyAccessSettings() async {
    try {
      final res = await _dndChannel
          .invokeMethod<bool>('openNotificationPolicyAccessSettings');
      return res ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Error opening DND policy settings: $e');
      }
      return false;
    }
  }

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
    // Read the actual local timezone from the device instead of relying on UTC offsets
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      String tzId = timeZoneInfo.identifier;
      // Map legacy IDs to modern IANA names
      tzId = _legacyTimezoneMap[tzId] ?? tzId;
      tz.setLocalLocation(tz.getLocation(tzId));
      if (kDebugMode) debugPrint('[NotificationService] Timezone set to: $tzId');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Failed to set timezone: $e, falling back to UTC');
      }
      try {
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

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) debugPrint('Notification clicked: ');
      },
    );

    // Create high-priority alarm channel on Android that routes audio to Alarm stream to bypass DND
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidPlugin?.deleteNotificationChannel('medical_emergency_channel');
    } catch (_) {}
    await androidPlugin?.createNotificationChannel(medicineChannel);

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
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
    tz.TZDateTime doseTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (kDebugMode) {
      debugPrint(
          '[NotificationService] Scheduling: now=$now, doseTime=$doseTime, timeString=$timeString');
    }

    if (doseTime.isBefore(now)) {
      // Fix DST: use constructor instead of Duration(days: 1)
      doseTime =
          tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, hour, minute);
    }

    tz.TZDateTime scheduledDate = doseTime.subtract(const Duration(minutes: 5));

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      medicineChannelId,
      medicineChannelName,
      channelDescription: medicineChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm_loud'),
      visibility: NotificationVisibility.private, // Private hides payload on lock screen
      fullScreenIntent: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    );

    if (scheduledDate.isBefore(now)) {
      if (doseTime.isAfter(now)) {
        // The dose is today and happening in < 5 mins!
        // To avoid shifting the DAILY alarm to right now permanently, 
        // we fire a one-off immediate alarm for today's dose!
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id + 10000, // Offset ID so it doesn't conflict
          'Time for your medicine',
          'It is time to take your scheduled dose.',
          now.add(const Duration(seconds: 5)),
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
      }

      // Fix DST: use constructor instead of Duration(days: 1)
      scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day + 1,
        scheduledDate.hour,
        scheduledDate.minute,
      );
    }

    if (kDebugMode) {
      debugPrint(
          '[NotificationService] Final scheduledDate=$scheduledDate for id=$id');
    }

    // Neutral notification bodies to protect privacy on lock screens
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time for your medicine',
      'It is time to take your scheduled dose.',
      scheduledDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
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
      0,
    );

    if (testDay8am.isBefore(now) &&
        DateTime(date.year, date.month, date.day)
            .isBefore(DateTime(now.year, now.month, now.day))) {
      return;
    }

    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, testDay8am.year, testDay8am.month, testDay8am.day - 3, 8, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
          tz.local, testDay8am.year, testDay8am.month, testDay8am.day - 1, 8, 0);
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = testDay8am;
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = now.add(const Duration(seconds: 5));
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      medicineChannelId,
      medicineChannelName,
      channelDescription: medicineChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.reminder,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm_loud'),
      visibility: NotificationVisibility.private,
      fullScreenIntent: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Upcoming Diagnostic Test',
      'You have a scheduled test coming up.',
      scheduledDate,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
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
      'Refill Alerts',
      channelDescription: 'Alerts when your medicine stock is running low',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.secret,
    );

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
