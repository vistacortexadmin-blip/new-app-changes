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

  Map<String, dynamic> toJson() => {
    'timeOfDay': timeOfDay.index,
    'timeString': timeString,
    'status': status.index,
    'loggedAt': loggedAt?.toIso8601String(),
    'skipReason': skipReason,
  };
  
  factory DoseSchedule.fromJson(Map<String, dynamic> json) => DoseSchedule(
    timeOfDay: DoseTimeOfDay.values[json['timeOfDay']],
    timeString: json['timeString'],
    status: AdherenceStatus.values[json['status']],
    loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
    skipReason: json['skipReason'],
  );

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
  final String? warning;

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
    this.warning,
  });

  int get daysOfSupplyRemaining {
    if (dailyDoseCount <= 0) return 999; // Not applicable
    return (totalQuantityAvailable / dailyDoseCount).floor();
  }

  DateTime get estimatedRefillDate {
    return DateTime.now().add(Duration(days: daysOfSupplyRemaining));
  }

  bool get isLowSupply => daysOfSupplyRemaining <= 5;
  bool get isCriticalSupply => daysOfSupplyRemaining <= 2;

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicineName': medicineName,
    'dosage': dosage,
    'instructions': instructions,
    'prescribedFor': prescribedFor,
    'dailySchedules': dailySchedules.map((e) => e.toJson()).toList(),
    'totalQuantityAvailable': totalQuantityAvailable,
    'dailyDoseCount': dailyDoseCount,
    'startDate': startDate.toIso8601String(),
    'durationDays': durationDays,
    'warning': warning,
  };
  
  factory MedicineReminder.fromJson(Map<String, dynamic> json) => MedicineReminder(
    id: json['id'],
    medicineName: json['medicineName'],
    dosage: json['dosage'],
    instructions: json['instructions'],
    prescribedFor: json['prescribedFor'],
    dailySchedules: (json['dailySchedules'] as List).map((e) => DoseSchedule.fromJson(e)).toList(),
    totalQuantityAvailable: json['totalQuantityAvailable'],
    dailyDoseCount: json['dailyDoseCount'],
    startDate: DateTime.parse(json['startDate']),
    durationDays: json['durationDays'],
    warning: json['warning'],
  );

  MedicineReminder copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? instructions,
    String? prescribedFor,
    List<DoseSchedule>? dailySchedules,
    int? totalQuantityAvailable,
    int? dailyDoseCount,
    DateTime? startDate,
    int? durationDays,
    String? warning,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      prescribedFor: prescribedFor ?? this.prescribedFor,
      dailySchedules: dailySchedules ?? this.dailySchedules,
      totalQuantityAvailable: totalQuantityAvailable ?? this.totalQuantityAvailable,
      dailyDoseCount: dailyDoseCount ?? this.dailyDoseCount,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      warning: warning ?? this.warning,
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
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final testDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    return testDay.difference(today).inDays;
  }

  bool get isOverdue => daysUntilTest < 0 && !isCompleted;
  Map<String, dynamic> toJson() => {
    'id': id,
    'testName': testName,
    'labOrClinicName': labOrClinicName,
    'scheduledDate': scheduledDate.toIso8601String(),
    'preparationInstructions': preparationInstructions,
    'isCompleted': isCompleted,
    'relatedReportId': relatedReportId,
  };
  
  factory NextTestReminder.fromJson(Map<String, dynamic> json) => NextTestReminder(
    id: json['id'],
    testName: json['testName'],
    labOrClinicName: json['labOrClinicName'],
    scheduledDate: DateTime.parse(json['scheduledDate']),
    preparationInstructions: json['preparationInstructions'],
    isCompleted: json['isCompleted'],
    relatedReportId: json['relatedReportId'],
  );

}
