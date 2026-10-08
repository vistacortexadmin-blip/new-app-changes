import sys
import re

file_path = 'lib/features/reminders/models/reminder_model.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

dose_json = '''  Map<String, dynamic> toJson() => {
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
'''

medicine_json = '''  Map<String, dynamic> toJson() => {
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
'''

test_json = '''  Map<String, dynamic> toJson() => {
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
'''

content = content.replace('  DoseSchedule copyWith({', dose_json + '\n  DoseSchedule copyWith({')
content = content.replace('  MedicineReminder copyWith({', medicine_json + '\n  MedicineReminder copyWith({')
content = content.replace('  bool get isOverdue => daysUntilTest < 0 && !isCompleted;', '  bool get isOverdue => daysUntilTest < 0 && !isCompleted;\n' + test_json)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
