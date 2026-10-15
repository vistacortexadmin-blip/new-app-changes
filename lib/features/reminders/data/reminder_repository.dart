import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/notifications/notification_service.dart';
import '../models/reminder.dart';
import 'reminder_api_service.dart';

class ReminderRepository {
  final Box<Reminder> _box;
  final ReminderApiService? _api;
  final Uuid _uuid = const Uuid();

  ReminderRepository(this._box, {ReminderApiService? api}) : _api = api;

  List<Reminder> get all => _box.values.toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

  bool get hasCloud => _api != null;

  // ---------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------
  Future<Reminder> addReminder({
    required String title,
    required ReminderType type,
    required DateTime scheduledTime,
    required ReminderSource source,
    bool isRecurring = false,
    RecurringSlot? recurringSlot,
    // ignore: constant_identifier_names
    ReminderFrequency frequency = ReminderFrequency.ONCE,
    NotificationType notificationType = NotificationType.SOUND,
    String? relatedTestId,
    String? foodRelation,
    String? doctorName,
    String soundLevel = 'high',
    String vibrationLevel = 'medium',
    bool flashLed = true,
    bool screenAlert = false,
    bool showDetailsOnLockScreen = false,
  }) async {
    final now = DateTime.now();
    final reminder = Reminder(
      id: _uuid.v4(),
      userId: 'local',
      title: title,
      type: type.name.toLowerCase(),
      scheduledTime: scheduledTime,
      isRecurring: isRecurring,
      recurringSlot: recurringSlot?.name,
      source: source.name.toLowerCase(),
      status: ReminderStatus.pending.name.toLowerCase(),
      relatedTestId: relatedTestId,
      createdAt: now,
      updatedAt: now,
      isSynced: _api == null,
      isEnabled: true,
      foodRelation: foodRelation,
      doctorName: doctorName,
      soundLevel: soundLevel,
      vibrationLevel: vibrationLevel,
      flashLed: flashLed,
      screenAlert: screenAlert,
      showDetailsOnLockScreen: showDetailsOnLockScreen,
    );

    await _box.put(reminder.id, reminder);

    await NotificationService.instance.scheduleReminder(
      id: reminder.id,
      title: reminder.title,
      body: _notificationBody(reminder),
      when: reminder.scheduledTime,
      daily: reminder.isRecurring,
      soundLevel: reminder.soundLevel,
      vibrationLevel: reminder.vibrationLevel,
      flashLed: reminder.flashLed,
      screenAlert: reminder.screenAlert,
      showDetailsOnLockScreen: reminder.showDetailsOnLockScreen,
    );

    // Fire-and-forget cloud sync.
    unawaited(_trySync(reminder));
    return reminder;
  }

  // ---------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------
  Future<void> updateReminder(
    String id, {
    String? title,
    DateTime? scheduledTime,
    String? foodRelation,
    String? doctorName,
    bool? isEnabled,
    bool? isRecurring,
    RecurringSlot? recurringSlot,
    String? soundLevel,
    String? vibrationLevel,
    bool? flashLed,
    bool? screenAlert,
    bool? showDetailsOnLockScreen,
  }) async {
    final current = _box.get(id);
    if (current == null) return;

    final updated = current.copyWith(
      title: title,
      scheduledTime: scheduledTime,
      foodRelation: foodRelation,
      doctorName: doctorName,
      isEnabled: isEnabled,
      isRecurring: isRecurring,
      recurringSlot:
          recurringSlot != null ? recurringSlot.name : current.recurringSlot,
      soundLevel: soundLevel,
      vibrationLevel: vibrationLevel,
      flashLed: flashLed,
      screenAlert: screenAlert,
      showDetailsOnLockScreen: showDetailsOnLockScreen,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _box.put(id, updated);

    if (updated.isEnabled) {
      await NotificationService.instance.scheduleReminder(
        id: updated.id,
        title: updated.title,
        body: _notificationBody(updated),
        when: updated.scheduledTime,
        daily: updated.isRecurring,
        soundLevel: updated.soundLevel,
        vibrationLevel: updated.vibrationLevel,
        flashLed: updated.flashLed,
        screenAlert: updated.screenAlert,
        showDetailsOnLockScreen: updated.showDetailsOnLockScreen,
      );
    } else {
      await NotificationService.instance.cancelReminder(updated.id);
    }

    unawaited(_trySync(updated));
  }

  // ---------------------------------------------------------------
  // STATUS
  // ---------------------------------------------------------------
  Future<void> updateStatus(String id, ReminderStatus status) async {
    final r = _box.get(id);
    if (r == null) return;
    final updated = r.copyWith(
      status: status.name.toLowerCase(),
      updatedAt: DateTime.now(),
      isSynced: _api == null,
    );
    await _box.put(id, updated);
    unawaited(_trySync(updated));
  }

  // ---------------------------------------------------------------
  // TOGGLE
  // ---------------------------------------------------------------
  Future<void> toggleEnabled(String id, bool enabled) async {
    final r = _box.get(id);
    if (r == null) return;

    final updated = r.copyWith(
      isEnabled: enabled,
      updatedAt: DateTime.now(),
      isSynced: _api == null,
    );
    await _box.put(id, updated);

    if (enabled) {
      await NotificationService.instance.scheduleReminder(
        id: updated.id,
        title: updated.title,
        body: _notificationBody(updated),
        when: updated.scheduledTime,
        daily: updated.isRecurring,
        soundLevel: updated.soundLevel,
        vibrationLevel: updated.vibrationLevel,
        flashLed: updated.flashLed,
        screenAlert: updated.screenAlert,
        showDetailsOnLockScreen: updated.showDetailsOnLockScreen,
      );
    } else {
      await NotificationService.instance.cancelReminder(updated.id);
    }

    unawaited(_trySync(updated));
  }

  // ---------------------------------------------------------------
  // RESCHEDULE
  // ---------------------------------------------------------------
  Future<void> reschedule(String id, DateTime newTime) async {
    await updateReminder(id, scheduledTime: newTime);
  }

  // ---------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------
  Future<void> deleteReminder(String id) async {
    await NotificationService.instance.cancelReminder(id);
    await _box.delete(id);

    final api = _api; // ← NEW: local non-null reference
    if (api != null) {
      try {
        await api.delete(id); // ← uses `api`, not `_api`
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------
  // SYNC
  // ---------------------------------------------------------------
  Future<void> syncPending() async {
    if (_api == null) return;
    final pending = _box.values.where((r) => !r.isSynced).toList();
    for (final r in pending) {
      await _trySync(r);
    }
  }

  Future<void> pullFromCloud() async {
    final api = _api;
    if (api == null) return;
    try {
      final cloud = await api.fetchAll();
      for (final c in cloud) {
        final local = _box.get(c.id);
        if (local == null || local.updatedAt.isBefore(c.updatedAt)) {
          await _box.put(c.id, c);
        }
      }
    } catch (_) {}
  }

  Future<void> _trySync(Reminder r) async {
    final api = _api;
    if (api == null) return;
    try {
      final existing = _box.containsKey(r.id);
      if (existing && r.isSynced) {
        await api.update(r);
      } else {
        await api.create(r);
      }
      await _box.put(r.id, r.copyWith(isSynced: true));
    } catch (_) {}
  }

  // ---------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------
  String _notificationBody(Reminder r) {
    final t = r.type.toLowerCase();
    if (t == 'medicine') {
      final food = r.foodRelation != null ? ' (${r.foodRelation} food)' : '';
      return 'Time for your medicine$food';
    }
    if (t == 'test') return 'Upcoming lab test';
    if (r.doctorName != null && r.doctorName!.isNotEmpty) {
      return 'Follow-up with ${r.doctorName}';
    }
    return 'Time for your reminder';
  }
}

// Local helper so we don't await fire-and-forget syncs.
void unawaited(Future<void> f) {}
