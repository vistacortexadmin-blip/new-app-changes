import 'package:hive_ce/hive_ce.dart';

part 'reminder.g.dart';

// ignore: constant_identifier_names
enum ReminderType { MEDICINE, TEST, CUSTOM }

// ignore: constant_identifier_names
enum ReminderFrequency { ONCE, DAILY, WEEKLY, MONTHLY }

// ignore: constant_identifier_names
enum NotificationType { SOUND, VIBRATION, VISUAL, SILENT }

enum ReminderSource { auto, manual }
enum ReminderStatus { pending, taken, missed, snoozed }
enum RecurringSlot { morning, afternoon, evening, night }

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String userId;
  @HiveField(2) final String title;
  @HiveField(3) final String type;
  @HiveField(4) final DateTime scheduledTime;
  @HiveField(5) final bool isRecurring;
  @HiveField(6) final String? recurringSlot;
  @HiveField(7) final String source;
  @HiveField(8) final String status;
  @HiveField(9) final String? relatedTestId;
  @HiveField(10) final DateTime createdAt;
  @HiveField(11) final DateTime updatedAt;
  @HiveField(12) final bool isSynced;
  @HiveField(13) final bool isEnabled;
  @HiveField(14) final String? foodRelation; // 'before' | 'after'
  @HiveField(15) final String? doctorName;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.scheduledTime,
    this.isRecurring = false,
    this.recurringSlot,
    this.source = 'manual',
    this.status = 'pending',
    this.relatedTestId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isEnabled = true,
    this.foodRelation,
    this.doctorName,
  });

  Reminder copyWith({
    String? title,
    DateTime? scheduledTime,
    String? status,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isEnabled,
    String? foodRelation,
    String? doctorName,
  }) =>
      Reminder(
        id: id,
        userId: userId,
        title: title ?? this.title,
        type: type,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        isRecurring: isRecurring,
        recurringSlot: recurringSlot,
        source: source,
        status: status ?? this.status,
        relatedTestId: relatedTestId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        isEnabled: isEnabled ?? this.isEnabled,
        foodRelation: foodRelation ?? this.foodRelation,
        doctorName: doctorName ?? this.doctorName,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'type': type,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
        'is_recurring': isRecurring,
        'recurring_slot': recurringSlot,
        'source': source,
        'status': status,
        'related_test_id': relatedTestId,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'is_enabled': isEnabled,
        'food_relation': foodRelation,
        'doctor_name': doctorName,
      };

  factory Reminder.fromSupabase(Map<String, dynamic> row) => Reminder(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        title: row['title'] as String,
        type: row['type'] as String,
        scheduledTime:
            DateTime.parse(row['scheduled_time'] as String).toLocal(),
        isRecurring: row['is_recurring'] as bool? ?? false,
        recurringSlot: row['recurring_slot'] as String?,
        source: row['source'] as String? ?? 'manual',
        status: row['status'] as String? ?? 'pending',
        relatedTestId: row['related_test_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
        isSynced: true,
        isEnabled: row['is_enabled'] as bool? ?? true,
        foodRelation: row['food_relation'] as String?,
        doctorName: row['doctor_name'] as String?,
      );
}