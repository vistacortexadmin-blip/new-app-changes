enum DoseTimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

enum AdherenceStatus {
  pending,
  taken,
  skipped,
}

class DoseSchedule {
  final DoseTimeOfDay timeOfDay;
  final String timeString; // e.g. "08:00 AM"
  final AdherenceStatus status;
  final DateTime? loggedAt;
  final String? skipReason;

  DoseSchedule({
    required this.timeOfDay,
    required this.timeString,
    this.status = AdherenceStatus.pending,
    this.loggedAt,
    this.skipReason,
  });

  DoseSchedule copyWith({
    AdherenceStatus? status,
    DateTime? loggedAt,
    String? skipReason,
  }) {
    return DoseSchedule(
      timeOfDay: timeOfDay,
      timeString: timeString,
      status: status ?? this.status,
      loggedAt: loggedAt ?? this.loggedAt,
      skipReason: skipReason ?? this.skipReason,
    );
  }
}

class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosage; // e.g. "500 mg", "1 Tablet"
  final String instructions; // e.g. "After food"
  final String prescribedFor; // e.g. "Hypertension"
  final List<DoseSchedule> dailySchedules;
  final int totalQuantityAvailable;
  final int dailyDoseCount;
  final DateTime startDate;
  final int durationDays;

  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.instructions,
    required this.prescribedFor,
    required this.dailySchedules,
    required this.totalQuantityAvailable,
    required this.dailyDoseCount,
    required this.startDate,
    required this.durationDays,
  });

  int get daysOfSupplyRemaining {
    if (dailyDoseCount <= 0) return 0;
    return (totalQuantityAvailable / dailyDoseCount).floor();
  }

  DateTime get estimatedRefillDate {
    return DateTime.now().add(Duration(days: daysOfSupplyRemaining));
  }

  bool get isLowSupply => daysOfSupplyRemaining <= 5;
  bool get isCriticalSupply => daysOfSupplyRemaining <= 2;

  MedicineReminder copyWith({
    List<DoseSchedule>? dailySchedules,
    int? totalQuantityAvailable,
  }) {
    return MedicineReminder(
      id: id,
      medicineName: medicineName,
      dosage: dosage,
      instructions: instructions,
      prescribedFor: prescribedFor,
      dailySchedules: dailySchedules ?? this.dailySchedules,
      totalQuantityAvailable: totalQuantityAvailable ?? this.totalQuantityAvailable,
      dailyDoseCount: dailyDoseCount,
      startDate: startDate,
      durationDays: durationDays,
    );
  }
}

class NextTestReminder {
  final String id;
  final String testName;
  final String labOrClinicName;
  final DateTime scheduledDate;
  final String preparationInstructions;
  final bool isCompleted;
  final String? relatedReportId;

  NextTestReminder({
    required this.id,
    required this.testName,
    required this.labOrClinicName,
    required this.scheduledDate,
    required this.preparationInstructions,
    this.isCompleted = false,
    this.relatedReportId,
  });

  int get daysUntilTest {
    final now = DateTime.now();
    final difference = scheduledDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return difference;
  }

  bool get isOverdue => daysUntilTest < 0 && !isCompleted;
}
