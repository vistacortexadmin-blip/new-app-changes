import 'package:hive_ce/hive_ce.dart';

part 'reminder.g.dart';

// ignore: constant_identifier_names
enum ReminderType { MEDICINE, TEST, CUSTOM }

// ignore: constant_identifier_names
enum ReminderFrequency { ONCE, DAILY, WEEKLY, MONTHLY }

// ignore: constant_identifier_names
enum NotificationType { SOUND, VIBRATION, VISUAL, SILENT }

// Sound level: high, medium, low, silent
// Vibration level: high, medium, low, off
enum ReminderSource { auto, manual }

enum ReminderStatus { pending, taken, missed, snoozed }

enum RecurringSlot { morning, afternoon, evening, night }

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final DateTime scheduledTime;
  @HiveField(5)
  final bool isRecurring;
  @HiveField(6)
  final String? recurringSlot;
  @HiveField(7)
  final String source;
  @HiveField(8)
  final String status;
  @HiveField(9)
  final String? relatedTestId;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;
  @HiveField(12)
  final bool isSynced;
  @HiveField(13)
  final bool isEnabled;
  @HiveField(14)
  final String? foodRelation;
  @HiveField(15)
  final String? doctorName;
  // Notification settings
  @HiveField(16)
  final String soundLevel; // 'high' | 'medium' | 'low' | 'silent'
  @HiveField(17)
  final String vibrationLevel; // 'high' | 'medium' | 'low' | 'off'
  @HiveField(18)
  final bool flashLed;
  @HiveField(19)
  final bool screenAlert;
  // H5 fix — hide full name on lock screen by default
  @HiveField(20)
  final bool showDetailsOnLockScreen;

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
    this.soundLevel = 'high',
    this.vibrationLevel = 'medium',
    this.flashLed = true,
    this.screenAlert = false,
    this.showDetailsOnLockScreen = false,
  });

  Reminder copyWith({
    String? title,
    DateTime? scheduledTime,
    String? status,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isEnabled,
    bool? isRecurring,
    String? recurringSlot,
    String? foodRelation,
    String? doctorName,
    String? soundLevel,
    String? vibrationLevel,
    bool? flashLed,
    bool? screenAlert,
    bool? showDetailsOnLockScreen,
  }) =>
      Reminder(
        id: id,
        userId: userId,
        title: title ?? this.title,
        type: type,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringSlot: recurringSlot ?? this.recurringSlot,
        source: source,
        status: status ?? this.status,
        relatedTestId: relatedTestId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        isEnabled: isEnabled ?? this.isEnabled,
        foodRelation: foodRelation ?? this.foodRelation,
        doctorName: doctorName ?? this.doctorName,
        soundLevel: soundLevel ?? this.soundLevel,
        vibrationLevel: vibrationLevel ?? this.vibrationLevel,
        flashLed: flashLed ?? this.flashLed,
        screenAlert: screenAlert ?? this.screenAlert,
        showDetailsOnLockScreen:
            showDetailsOnLockScreen ?? this.showDetailsOnLockScreen,
      );

  /// Serializes to JSON. Field names match the reminders table
  /// (previously consumed by Supabase — now consumed by the app server).
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
        'sound_level': soundLevel,
        'vibration_level': vibrationLevel,
        'flash_led': flashLed,
        'screen_alert': screenAlert,
        'show_details_on_lock_screen': showDetailsOnLockScreen,
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
        soundLevel: row['sound_level'] as String? ?? 'high',
        vibrationLevel: row['vibration_level'] as String? ?? 'medium',
        flashLed: row['flash_led'] as bool? ?? true,
        screenAlert: row['screen_alert'] as bool? ?? false,
        showDetailsOnLockScreen:
            row['show_details_on_lock_screen'] as bool? ?? false,
      );
}
