import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reminder.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  static const _tabs = [
    (label: 'All', value: null),
    (label: 'Medicines', value: 'MEDICINE'),
    (label: 'Tests', value: 'TEST'),
    (label: 'Follow-ups', value: 'CUSTOM'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filteredRemindersProvider);
    final active = ref.watch(reminderFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            tooltip: 'Sync from cloud',
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () =>
                ref.read(reminderRepositoryProvider).pullFromCloud(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _tabs.map((t) {
                final selected = active == t.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.label),
                    selected: selected,
                    onSelected: (_) => ref
                        .read(reminderFilterProvider.notifier)
                        .state = t.value,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No reminders here yet.\nTap + to add one, or book a test.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ReminderTile(reminder: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Add sheet ----------
  Future<void> _openAddSheet(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    var type = ReminderType.MEDICINE;
    var when = DateTime.now().add(const Duration(hours: 1));
    var foodRelation = 'after';
    final slots = <RecurringSlot>{
      RecurringSlot.morning,
      RecurringSlot.afternoon,
      RecurringSlot.evening,
      RecurringSlot.night,
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New Reminder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: type == ReminderType.MEDICINE
                        ? 'Medicine name'
                        : type == ReminderType.TEST
                            ? 'Test name'
                            : 'Reason (e.g., Cardio follow-up)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReminderType>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ReminderType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_label(t)),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() => type = v!),
                ),
                const SizedBox(height: 12),
                if (type == ReminderType.CUSTOM) ...[
                  TextField(
                    controller: doctorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Doctor name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (type == ReminderType.MEDICINE) ...[
                  const Text(
                    'Slots',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: RecurringSlot.values.map((s) {
                      final on = slots.contains(s);
                      return FilterChip(
                        label: Text(_slotLabel(s)),
                        selected: on,
                        onSelected: (v) => setSheet(() {
                          if (v) {
                            slots.add(s);
                          } else {
                            slots.remove(s);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: foodRelation,
                    decoration: const InputDecoration(
                      labelText: 'Food relation',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'before',
                        child: Text('Before food'),
                      ),
                      DropdownMenuItem(
                        value: 'after',
                        child: Text('After food'),
                      ),
                    ],
                    onChanged: (v) => setSheet(() => foodRelation = v!),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    'Time: ${TimeOfDay.fromDateTime(when).format(ctx)}',
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(when),
                    );
                    if (picked != null) {
                      setSheet(() {
                        when = DateTime(
                          when.year,
                          when.month,
                          when.day,
                          picked.hour,
                          picked.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    final repo = ref.read(reminderRepositoryProvider);
                    final doctor = doctorCtrl.text.trim();

                    if (type == ReminderType.MEDICINE && slots.isNotEmpty) {
                      const hours = {
                        RecurringSlot.morning: 8,
                        RecurringSlot.afternoon: 14,
                        RecurringSlot.evening: 18,
                        RecurringSlot.night: 21,
                      };
                      for (final s in slots) {
                        final t = DateTime(
                          when.year,
                          when.month,
                          when.day,
                          hours[s]!,
                          when.minute,
                        );
                        await repo.addReminder(
                          title: '$title — ${_slotLabel(s)}',
                          type: ReminderType.MEDICINE,
                          scheduledTime: t,
                          source: ReminderSource.manual,
                          isRecurring: true,
                          recurringSlot: s,
                          foodRelation: foodRelation,
                        );
                      }
                    } else {
                      await repo.addReminder(
                        title: title,
                        type: type,
                        scheduledTime: when,
                        source: ReminderSource.manual,
                        doctorName:
                            type == ReminderType.CUSTOM && doctor.isNotEmpty
                                ? doctor
                                : null,
                      );
                    }

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(ReminderType t) {
    switch (t) {
      case ReminderType.MEDICINE:
        return 'Medicine';
      case ReminderType.TEST:
        return 'Test';
      case ReminderType.CUSTOM:
        return 'Follow-up';
    }
  }

  String _slotLabel(RecurringSlot s) {
    switch (s) {
      case RecurringSlot.morning:
        return 'Morning';
      case RecurringSlot.afternoon:
        return 'Afternoon';
      case RecurringSlot.evening:
        return 'Evening';
      case RecurringSlot.night:
        return 'Night';
    }
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(reminderRepositoryProvider);
    final done = reminder.status.toLowerCase() == 'taken';
    final enabled = reminder.isEnabled;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Card(
        child: ListTile(
          leading: Icon(_icon(reminder.type)),
          title: Text(
            reminder.title,
            style: TextStyle(
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(_subtitle(reminder)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit time',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(reminder.scheduledTime),
                  );
                  if (picked != null) {
                    final newTime = DateTime(
                      reminder.scheduledTime.year,
                      reminder.scheduledTime.month,
                      reminder.scheduledTime.day,
                      picked.hour,
                      picked.minute,
                    );
                    await repo.reschedule(reminder.id, newTime);
                  }
                },
              ),
              Switch(
                value: enabled,
                onChanged: (v) => repo.toggleEnabled(reminder.id, v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Reminder reminder) {
    final parts = <String>[
      _typeLabel(reminder.type),
      _fmt(reminder.scheduledTime),
    ];

    if (reminder.doctorName != null && reminder.doctorName!.isNotEmpty) {
      parts.insert(1, reminder.doctorName!);
    }

    if (reminder.foodRelation != null && reminder.foodRelation!.isNotEmpty) {
      parts.add('${reminder.foodRelation} food');
    }

    return parts.join(' • ');
  }

  IconData _icon(String type) {
    switch (type.toUpperCase()) {
      case 'MEDICINE':
        return Icons.medication;
      case 'TEST':
        return Icons.science;
      case 'CUSTOM':
        return Icons.event_note;
      default:
        return Icons.notifications;
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'MEDICINE':
        return 'Medicine';
      case 'TEST':
        return 'Test';
      case 'CUSTOM':
        return 'Follow-up';
      default:
        return type;
    }
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $h:$m';
  }
}
