import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/notifications/notification_service.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final Box<Reminder> _box;
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  ReminderRepository(this._box, this._client);

  String? get _userId => _client.auth.currentUser?.id;

  List<Reminder> get all => _box.values.toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

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
  }) async {
    final now = DateTime.now();
    final reminder = Reminder(
      id: _uuid.v4(),
      userId: _userId ?? 'local',
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
      isSynced: false,
      isEnabled: true,
      foodRelation: foodRelation,
      doctorName: doctorName,
    );

    await _box.put(reminder.id, reminder);

    // Schedule the local notification (fires offline / app closed).
    await NotificationService.instance.scheduleReminder(
      id: reminder.id,
      title: reminder.title,
      body: 'Time for your ${reminder.type} reminder',
      when: reminder.scheduledTime,
      daily: reminder.isRecurring,
    );

    await _trySync(reminder);
    return reminder;
  }

  Future<void> updateStatus(String id, ReminderStatus status) async {
    final r = _box.get(id);
    if (r == null) return;
    final updated = r.copyWith(
      status: status.name.toLowerCase(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box.put(id, updated);
    await _trySync(updated);
  }

  Future<void> toggleEnabled(String id, bool enabled) async {
    final r = _box.get(id);
    if (r == null) return;

    final updated = r.copyWith(
      isEnabled: enabled,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box.put(id, updated);

    // Cancel the scheduled notification when disabled; reschedule when enabled.
    if (enabled) {
      await NotificationService.instance.scheduleReminder(
        id: updated.id,
        title: updated.title,
        body: 'Time for your ${updated.type} reminder',
        when: updated.scheduledTime,
        daily: updated.isRecurring,
      );
    } else {
      await NotificationService.instance.cancelReminder(updated.id);
    }

    await _trySync(updated);
  }

  Future<void> reschedule(String id, DateTime newTime) async {
    final r = _box.get(id);
    if (r == null) return;

    final updated = r.copyWith(
      scheduledTime: newTime,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box.put(id, updated);

    // Reschedule the local notification.
    await NotificationService.instance.scheduleReminder(
      id: updated.id,
      title: updated.title,
      body: 'Time for your ${updated.type} reminder',
      when: updated.scheduledTime,
      daily: updated.isRecurring,
    );

    await _trySync(updated);
  }

  Future<void> deleteReminder(String id) async {
    // Cancel the scheduled notification before deleting.
    await NotificationService.instance.cancelReminder(id);

    await _box.delete(id);
    if (_userId != null) {
      try {
        await _client.from('reminders').delete().eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> syncPending() async {
    final unsynced = _box.values.where((r) => !r.isSynced).toList();
    for (final r in unsynced) {
      await _trySync(r);
    }
  }

  Future<void> pullFromCloud() async {
    if (_userId == null) return;
    try {
      final rows = await _client
          .from('reminders')
          .select()
          .eq('user_id', _userId!)
          .order('scheduled_time');

      for (final row in rows) {
        final cloud = Reminder.fromSupabase(row);
        final local = _box.get(cloud.id);
        if (local == null ||
            local.updatedAt.isBefore(cloud.updatedAt) ||
            local.isSynced) {
          await _box.put(cloud.id, cloud);
        }
      }
    } catch (_) {}
  }

  Future<void> _trySync(Reminder r) async {
    if (_userId == null) return;
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    try {
      await _client.from('reminders').upsert(r.toSupabase(), onConflict: 'id');
      await _box.put(r.id, r.copyWith(isSynced: true));
    } catch (_) {}
  }

  Future<int> deleteDemoReminders() async {
    final keys = _box.keys
        .where((k) => _box.get(k)?.source == ReminderSource.auto.name)
        .toList();
    var count = 0;
    for (final k in keys) {
      final r = _box.get(k);
      if (r != null && r.title.toLowerCase().contains('demo')) {
        await _box.delete(k);
        count++;
      }
    }
    return count;
  }
}
