import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_colors.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  static const _tabs = [
    (label: 'All', value: null),
    (label: 'Medicines', value: 'medicine'),
    (label: 'Tests', value: 'test'),
    (label: 'Follow-ups', value: 'custom'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filteredRemindersProvider);
    final active = ref.watch(reminderFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh from cloud',
            icon: const Icon(Icons.cloud_sync_outlined),
            onPressed: () async {
              final repo = ref.read(reminderRepositoryProvider);
              await repo.pullFromCloud();
              await repo.syncPending();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminders synced'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm),
        label: const Text('New Reminder'),
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final allAsync = ref.watch(remindersStreamProvider);
              final all = allAsync.valueOrNull ?? const <Reminder>[];
              final enabled = all.where((r) => r.isEnabled).toList();

              int countFor(String? type) => type == null
                  ? enabled.length
                  : enabled.where((r) => r.type.toLowerCase() == type).length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: _tabs.map((t) {
                    final selected = active == t.value;
                    final count = countFor(t.value);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${t.label} ($count)'),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => ref
                            .read(reminderFilterProvider.notifier)
                            .state = t.value,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) return _EmptyState(filter: active);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReminderTile(reminder: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    var type = ReminderType.MEDICINE;
    var when = DateTime.now().add(const Duration(hours: 1));
    var foodRelation = 'after';
    var soundLevel = 'high';
    var vibrationLevel = 'medium';
    var flashLed = true;
    var screenAlert = false;
    var showDetailsOnLockScreen = false;
    var slots = <RecurringSlot>{
      RecurringSlot.morning,
      RecurringSlot.afternoon,
      RecurringSlot.evening,
      RecurringSlot.night,
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'New Reminder',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _TypeChip(
                      label: 'Medicine',
                      icon: Icons.medication,
                      color: const Color(0xFFEC4899),
                      selected: type == ReminderType.MEDICINE,
                      onTap: () => setSheet(() => type = ReminderType.MEDICINE),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Test',
                      icon: Icons.science,
                      color: const Color(0xFF2563EB),
                      selected: type == ReminderType.TEST,
                      onTap: () => setSheet(() => type = ReminderType.TEST),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Follow-up',
                      icon: Icons.event_note,
                      color: const Color(0xFFF59E0B),
                      selected: type == ReminderType.CUSTOM,
                      onTap: () => setSheet(() => type = ReminderType.CUSTOM),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: type == ReminderType.MEDICINE
                        ? 'Medicine name'
                        : type == ReminderType.TEST
                            ? 'Test name'
                            : 'Reason (e.g., Cardio follow-up)',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (type == ReminderType.CUSTOM) ...[
                  TextField(
                    controller: doctorCtrl,
                    decoration: InputDecoration(
                      labelText: 'Doctor name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (type == ReminderType.MEDICINE) ...[
                  const Text('Time slots',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: RecurringSlot.values.map((s) {
                      final on = slots.contains(s);
                      return FilterChip(
                        label: Text(_slotLabel(s)),
                        selected: on,
                        selectedColor:
                            const Color(0xFFEC4899).withValues(alpha: 0.15),
                        checkmarkColor: const Color(0xFFEC4899),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: foodRelation,
                    decoration: InputDecoration(
                      labelText: 'Food relation',
                      prefixIcon: const Icon(Icons.restaurant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'before', child: Text('Before food')),
                      DropdownMenuItem(
                          value: 'after', child: Text('After food')),
                    ],
                    onChanged: (v) => setSheet(() => foodRelation = v!),
                  ),
                  const SizedBox(height: 12),
                ],

                // ---------- Date + Time picker ----------
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          '${when.day}/${when.month}/${when.year}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: when,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setSheet(() {
                              when = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                when.hour,
                                when.minute,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.schedule, size: 18),
                        label: Text(
                          TimeOfDay.fromDateTime(when).format(ctx),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const _SectionTitle(icon: Icons.volume_up, text: 'Sound'),
                _ChoiceRow(
                  options: const ['high', 'medium', 'low', 'silent'],
                  value: soundLevel,
                  onChanged: (v) => setSheet(() => soundLevel = v),
                ),
                const SizedBox(height: 12),
                const _SectionTitle(icon: Icons.vibration, text: 'Vibration'),
                _ChoiceRow(
                  options: const ['high', 'medium', 'low', 'off'],
                  value: vibrationLevel,
                  onChanged: (v) => setSheet(() => vibrationLevel = v),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: flashLed,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Flash LED',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Light up the LED when alert fires'),
                  onChanged: (v) => setSheet(() => flashLed = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: screenAlert,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Show on screen',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pop up over other apps when it fires'),
                  onChanged: (v) => setSheet(() => screenAlert = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: showDetailsOnLockScreen,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Show name on lock screen',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle:
                      const Text('Off by default to protect your privacy'),
                  onChanged: (v) => setSheet(() => showDetailsOnLockScreen = v),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter a title first')),
                      );
                      return;
                    }

                    final repo = ref.read(reminderRepositoryProvider);
                    final messenger = ScaffoldMessenger.of(context);

                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.read(reminderFilterProvider.notifier).state = null;

                    try {
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
                            soundLevel: soundLevel,
                            vibrationLevel: vibrationLevel,
                            flashLed: flashLed,
                            screenAlert: screenAlert,
                            showDetailsOnLockScreen: showDetailsOnLockScreen,
                          );
                        }
                      } else {
                        await repo.addReminder(
                          title: title,
                          type: type,
                          scheduledTime: when,
                          source: ReminderSource.manual,
                          doctorName: type == ReminderType.CUSTOM
                              ? doctorCtrl.text.trim()
                              : null,
                          soundLevel: soundLevel,
                          vibrationLevel: vibrationLevel,
                          flashLed: flashLed,
                          screenAlert: screenAlert,
                          showDetailsOnLockScreen: showDetailsOnLockScreen,
                        );
                      }

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Reminder saved'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Save failed: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Save Reminder',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((o) {
        final selected = value == o;
        return ChoiceChip(
          label: Text(o[0].toUpperCase() + o.substring(1)),
          selected: selected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => onChanged(o),
        );
      }).toList(),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filter});
  final String? filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reminders yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              filter == null
                  ? 'Tap "New Reminder" to add your first one, or book a lab test from the Home tab.'
                  : 'Nothing in this category yet.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
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
    final (icon, color) = _iconAndColor(reminder.type);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(reminder),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 20, color: AppColors.textSecondary),
                onSelected: (v) async {
                  if (v == 'edit') {
                    await _openEditDialog(context, ref, reminder);
                  } else if (v == 'delete') {
                    await _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              Switch(
                value: enabled,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => repo.toggleEnabled(reminder.id, v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${reminder.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(reminderRepositoryProvider).deleteReminder(reminder.id);
    }
  }

  (IconData, Color) _iconAndColor(String type) {
    switch (type.toLowerCase()) {
      case 'medicine':
        return (Icons.medication, const Color(0xFFEC4899));
      case 'test':
        return (Icons.science, const Color(0xFF2563EB));
      case 'custom':
      case 'followup':
        return (Icons.event_note, const Color(0xFFF59E0B));
      default:
        return (Icons.notifications, AppColors.primary);
    }
  }

  String _subtitle(Reminder r) {
    final t = _typeLabel(r.type);
    final time = _fmt(r.scheduledTime);
    final food = r.foodRelation != null ? ' • ${r.foodRelation} food' : '';
    final doctor = r.doctorName != null && r.doctorName!.isNotEmpty
        ? ' • ${r.doctorName}'
        : '';
    return '$t • $time$food$doctor';
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'medicine':
        return 'Medicine';
      case 'test':
        return 'Test';
      case 'custom':
      case 'followup':
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

Future<void> _openEditDialog(
  BuildContext context,
  WidgetRef ref,
  Reminder reminder,
) async {
  final titleCtrl = TextEditingController(text: reminder.title);
  final doctorCtrl = TextEditingController(text: reminder.doctorName ?? '');
  var when = reminder.scheduledTime;
  var food = reminder.foodRelation ?? 'after';
  var sound = reminder.soundLevel;
  var vib = reminder.vibrationLevel;
  var flash = reminder.flashLed;
  var screen = reminder.screenAlert;
  var showLock = reminder.showDetailsOnLockScreen;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (reminder.type.toLowerCase() == 'medicine')
                DropdownButtonFormField<String>(
                  initialValue: food,
                  decoration: InputDecoration(
                    labelText: 'Food relation',
                    prefixIcon: const Icon(Icons.restaurant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'before', child: Text('Before food')),
                    DropdownMenuItem(value: 'after', child: Text('After food')),
                  ],
                  onChanged: (v) => setSheet(() => food = v!),
                ),
              if (reminder.type.toLowerCase() == 'custom')
                TextField(
                  controller: doctorCtrl,
                  decoration: InputDecoration(
                    labelText: 'Doctor name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ---------- Date + Time picker ----------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        '${when.day}/${when.month}/${when.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: when,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSheet(() {
                            when = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              when.hour,
                              when.minute,
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(
                        TimeOfDay.fromDateTime(when).format(ctx),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const _SectionTitle(icon: Icons.volume_up, text: 'Sound'),
              _ChoiceRow(
                options: const ['high', 'medium', 'low', 'silent'],
                value: sound,
                onChanged: (v) => setSheet(() => sound = v),
              ),
              const SizedBox(height: 12),
              const _SectionTitle(icon: Icons.vibration, text: 'Vibration'),
              _ChoiceRow(
                options: const ['high', 'medium', 'low', 'off'],
                value: vib,
                onChanged: (v) => setSheet(() => vib = v),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: flash,
                activeThumbColor: AppColors.primary,
                title: const Text('Flash LED'),
                onChanged: (v) => setSheet(() => flash = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: screen,
                activeThumbColor: AppColors.primary,
                title: const Text('Show on screen'),
                onChanged: (v) => setSheet(() => screen = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: showLock,
                activeThumbColor: AppColors.primary,
                title: const Text('Show name on lock screen'),
                subtitle: const Text('Off by default to protect your privacy'),
                onChanged: (v) => setSheet(() => showLock = v),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final repo = ref.read(reminderRepositoryProvider);
                  final messenger = ScaffoldMessenger.of(context);
                  final newTitle = titleCtrl.text.trim().isEmpty
                      ? null
                      : titleCtrl.text.trim();

                  if (ctx.mounted) Navigator.pop(ctx);

                  try {
                    await repo.updateReminder(
                      reminder.id,
                      title: newTitle,
                      scheduledTime: when,
                      foodRelation: reminder.type.toLowerCase() == 'medicine'
                          ? food
                          : null,
                      doctorName: reminder.type.toLowerCase() == 'custom'
                          ? doctorCtrl.text.trim()
                          : null,
                      soundLevel: sound,
                      vibrationLevel: vib,
                      flashLed: flash,
                      screenAlert: screen,
                      showDetailsOnLockScreen: showLock,
                    );
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Reminder updated'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
