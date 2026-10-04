import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  StreamSubscription? _supabaseSub;

  /// Called when user taps a notification. Step 8 will wire this to
  /// navigate to the Reminders tab.
  void Function(String? payload)? onNotificationTap;

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone()
            .timeout(const Duration(seconds: 3));
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      } catch (_) {
        // Fallback: keep default UTC.
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(android: android, iOS: ios);

      await _local.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          onNotificationTap?.call(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationResponse,
      );

      await requestPermissions();
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.init failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      final android = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();

      final ios = _local.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.requestPermissions failed: $e');
    }
  }

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime when,
    bool daily = false,
  }) async {
    try {
      final scheduled = tz.TZDateTime.from(when, tz.local);

      await _local.zonedSchedule(
        id: id.hashCode,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Medication, test and follow-up reminders',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            ticker: 'Reminder',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: daily ? DateTimeComponents.time : null,
        payload: id,
      );
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.scheduleReminder failed for $id: $e');
    }
  }

  Future<void> cancelReminder(String id) async {
    try {
      await _local.cancel(id: id.hashCode);
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.cancelReminder failed for $id: $e');
    }
  }

  Future<void> showSystemNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    try {
      await _local.show(
        id: id.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'system_channel',
            'System alerts',
            channelDescription: 'Report, test and account notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: id,
      );
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService.showSystemNotification failed: $e');
    }
  }

  void listenToSupabaseNotifications(String userId) {
    _supabaseSub?.cancel();

    _supabaseSub = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .listen((rows) {
          for (final row in rows) {
            final isRead = row['is_read'] == true;
            if (!isRead) {
              showSystemNotification(
                id: row['id'] as String,
                title: row['title'] as String? ?? 'Notification',
                body: row['body'] as String? ?? '',
              );
            }
          }
        });
  }

  void dispose() {
    _supabaseSub?.cancel();
  }
}

/// Top-level, public, isolate entry point.
/// Must NOT be private (no leading underscore) — the isolate can't find it.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  // Step 8: route by payload to open Reminders tab on next launch.
}
