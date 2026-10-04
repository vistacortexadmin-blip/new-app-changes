import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/reminder_repository.dart';
import '../models/reminder.dart';

// ---------- Repository ----------
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(
    Hive.box<Reminder>('reminders'),
    Supabase.instance.client,
  );
});

// ---------- Live stream from Hive ----------
final remindersStreamProvider =
    StreamProvider.autoDispose<List<Reminder>>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  final box = Hive.box<Reminder>('reminders');

  return Stream<List<Reminder>>.multi((controller) {
    controller.add(repo.all);
    final sub = box.watch().listen((_) => controller.add(repo.all));
    controller.onCancel = sub.cancel;
  });
});

// ---------- Filter (null = All, else MEDICINE / TEST / CUSTOM) ----------
final reminderFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// ---------- Filtered list for the screen ----------
final filteredRemindersProvider =
    Provider.autoDispose<AsyncValue<List<Reminder>>>((ref) {
  final async = ref.watch(remindersStreamProvider);
  final filter = ref.watch(reminderFilterProvider);

  return async.whenData((list) {
    if (filter == null) return list;
    return list.where((r) => r.type.toUpperCase() == filter).toList();
  });
});

// ---------- Today count (for Home badge / Bell) ----------
final todayReminderCountProvider = Provider.autoDispose<int>((ref) {
  final list = ref.watch(remindersStreamProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  return list.where((r) {
    return r.scheduledTime.year == now.year &&
        r.scheduledTime.month == now.month &&
        r.scheduledTime.day == now.day;
  }).length;
});
