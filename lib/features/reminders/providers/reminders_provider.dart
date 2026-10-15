import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/reminder_api_service.dart';
import '../data/reminder_repository.dart';
import '../models/reminder.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  // Endpoint comes from --dart-define=VISTACORTEX_REMINDERS_API_URL=...
  // Same pattern as VISTACORTEX_ANALYSIS_API_URL in reports_provider.dart
  const configuredUrl = String.fromEnvironment('VISTACORTEX_REMINDERS_API_URL');
  final endpoint = Uri.tryParse(configuredUrl.trim());

  final validEndpoint = endpoint != null &&
      endpoint.hasScheme &&
      (endpoint.isScheme('https') ||
          (endpoint.isScheme('http') && endpoint.host == '10.0.2.2'));

  final api = validEndpoint
      ? ReminderApiService(
          baseUrl: endpoint,
          authTokenProvider: () async {
            try {
              return await FirebaseAuth.instance.currentUser?.getIdToken();
            } catch (_) {
              return null;
            }
          },
        )
      : null;

  return ReminderRepository(
    Hive.box<Reminder>('reminders'),
    api: api,
  );
});

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

final reminderFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final filteredRemindersProvider =
    Provider.autoDispose<AsyncValue<List<Reminder>>>((ref) {
  final async = ref.watch(remindersStreamProvider);
  final filter = ref.watch(reminderFilterProvider);

  return async.whenData((list) {
    if (filter == null) return list;
    return list
        .where((r) => r.type.toLowerCase() == filter.toLowerCase())
        .toList();
  });
});
