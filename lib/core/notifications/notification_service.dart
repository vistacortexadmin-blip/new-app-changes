import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'vistacortex_reminders_v2';
  static const String _channelName = 'Health Reminders';
  static const String _channelDesc =
      'Medication, lab test and follow-up reminders';

  bool _initialized = false;
  Future<void>? _initializing;

  // Deterministic notification ID. The same reminder ID always maps
  // to the same integer, allowing updates and cancellation.
  int _notificationId(String value) {
    var hash = 0x811C9DC5;

    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  Future<void> init() async {
    if (_initialized) return;

    final existing = _initializing;
    if (existing != null) {
      await existing;
      return;
    }

    final future = _initializeInternal();
    _initializing = future;

    try {
      await future;
      _initialized = true;
      debugPrint('[Notifications] Initialization successful');
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'VistaCortex notifications',
          context: ErrorDescription(
            'while initializing notifications',
          ),
        ),
      );
      rethrow;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initializeInternal() async {
    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _local.initialize(settings: settings);

    await _requestPermissions();
    await _createChannel();
  }

  Future<void> _requestPermissions() async {
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final notificationsGranted =
        await android?.requestNotificationsPermission();

    debugPrint(
      '[Notifications] Notification permission: $notificationsGranted',
    );

    final exactAlarmsAllowed = await android?.requestExactAlarmsPermission();

    debugPrint(
      '[Notifications] Exact alarm permission: $exactAlarmsAllowed',
    );

    final ios = _local.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _createChannel() async {
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  NotificationDetails _buildDetails({
    required String soundLevel,
    required String vibrationLevel,
  }) {
    final importance = soundLevel == 'silent'
        ? Importance.low
        : soundLevel == 'low'
            ? Importance.defaultImportance
            : Importance.max;

    final priority = soundLevel == 'silent'
        ? Priority.low
        : soundLevel == 'low'
            ? Priority.defaultPriority
            : Priority.high;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: importance,
        priority: priority,
        category: AndroidNotificationCategory.reminder,
        playSound: soundLevel != 'silent',
        enableVibration: vibrationLevel != 'off',
        // Intentionally omit LED settings. Some Android/plugin
        // combinations throw invalid_led_details when LED timings
        // are missing or unsupported.
        visibility: NotificationVisibility.private,
        ticker: 'Health reminder',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundLevel != 'silent',
        interruptionLevel: soundLevel == 'high'
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
    );
  }

  String _safeTitle(String title, bool showDetails) =>
      showDetails ? title : 'Time for your reminder';

  String _safeBody(String body, bool showDetails) =>
      showDetails ? body : 'Open VistaCortex for details';

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime when,
    bool daily = false,
    String soundLevel = 'high',
    String vibrationLevel = 'medium',
    bool flashLed = false,
    bool screenAlert = false,
    bool showDetailsOnLockScreen = false,
  }) async {
    await init();

    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty');
    }

    var scheduled = tz.TZDateTime.from(when, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (daily) {
      // Preserve the selected local time and find the next occurrence.
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduled.hour,
        scheduled.minute,
        scheduled.second,
      );

      if (!scheduled.isAfter(now)) {
        scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + 1,
          scheduled.hour,
          scheduled.minute,
          scheduled.second,
        );
      }

      if (scheduled.difference(now).inSeconds < 300) {
        throw ArgumentError(
          'Daily reminders must be scheduled at least '
          '5 minutes in the future.',
        );
      }
    } else if (!scheduled.isAfter(now)) {
      throw ArgumentError.value(
        when,
        'when',
        'A one-time reminder must be in the future.',
      );
    }

    final details = _buildDetails(
      soundLevel: soundLevel,
      vibrationLevel: vibrationLevel,
    );

    try {
      await _scheduleWithFallback(
        notificationId: _notificationId(id),
        title: _safeTitle(title, showDetailsOnLockScreen),
        body: _safeBody(body, showDetailsOnLockScreen),
        scheduled: scheduled,
        details: details,
        daily: daily,
        payload: id,
      );

      debugPrint(
        '[Notifications] Scheduled id=$id at=$scheduled daily=$daily',
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'VistaCortex notifications',
          context: ErrorDescription(
            'while scheduling reminder $id',
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _scheduleWithFallback({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime scheduled,
    required NotificationDetails details,
    required bool daily,
    required String payload,
  }) async {
    try {
      await _local.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: daily ? DateTimeComponents.time : null,
        payload: payload,
      );
    } catch (exactError, exactStack) {
      debugPrint(
        '[Notifications] Exact scheduling failed: $exactError',
      );

      try {
        await _local.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: daily ? DateTimeComponents.time : null,
          payload: payload,
        );

        debugPrint('[Notifications] Inexact fallback scheduled');
      } catch (fallbackError, fallbackStack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: fallbackError,
            stack: fallbackStack,
            library: 'VistaCortex notifications',
            context: ErrorDescription(
              'Inexact scheduling failed: $fallbackError. '
              'Exact scheduling error: $exactError\n$exactStack',
            ),
          ),
        );
        rethrow;
      }
    }
  }

  Future<void> cancelReminder(String id) async {
    await init();
    await _local.cancel(id: _notificationId(id));
    debugPrint('[Notifications] Cancelled reminder id=$id');
  }

  Future<void> cancelAll() async {
    await init();
    await _local.cancelAll();
    debugPrint('[Notifications] Cancelled all notifications');
  }

  Future<void> showSystemNotification({
    required String id,
    required String title,
    required String body,
    String soundLevel = 'high',
    String vibrationLevel = 'medium',
    bool flashLed = false,
    bool screenAlert = false,
    bool showDetailsOnLockScreen = false,
  }) async {
    await init();

    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty');
    }

    final details = _buildDetails(
      soundLevel: soundLevel,
      vibrationLevel: vibrationLevel,
    );

    try {
      await _local.show(
        id: _notificationId(id),
        title: _safeTitle(title, showDetailsOnLockScreen),
        body: _safeBody(body, showDetailsOnLockScreen),
        notificationDetails: details,
        payload: id,
      );

      debugPrint('[Notifications] Immediate notification displayed: $id');
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'VistaCortex notifications',
          context: ErrorDescription(
            'while displaying notification $id',
          ),
        ),
      );
      rethrow;
    }
  }
}
