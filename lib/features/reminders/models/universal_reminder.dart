enum ReminderType { MEDICINE, TEST, CUSTOM }

enum NotificationType { SOUND, VIBRATION, VISUAL, SILENT }

enum ReminderFrequency { ONCE, DAILY, WEEKLY, MONTHLY }

class UniversalReminder {
  final String id;
  final String title;
  final String itemId;
  final ReminderType type;
  final DateTime time;
  final ReminderFrequency frequency;
  final List<int> selectedDays;
  final NotificationType notificationType;
  final bool isActive;

  UniversalReminder({
    required this.id,
    required this.title,
    required this.itemId,
    required this.type,
    required this.time,
    required this.frequency,
    required this.selectedDays,
    required this.notificationType,
    this.isActive = true,
  });
}
