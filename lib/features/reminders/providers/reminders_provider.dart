import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/storage/seed_data.dart';
import '../../../core/services/notification_service.dart';

class RemindersState {
  final List<MedicineReminder> medicines;
  final List<NextTestReminder> nextTests;
  final DoseTimeOfDay selectedTimeFilter;

  RemindersState({
    required this.medicines,
    required this.nextTests,
    this.selectedTimeFilter = DoseTimeOfDay.morning,
  });

  List<MedicineReminder> get lowSupplyMedicines =>
      medicines.where((m) => m.isLowSupply).toList();

  List<NextTestReminder> get upcomingTests =>
      nextTests.where((t) => !t.isCompleted).toList();

  int get pendingDosesTodayCount {
    int count = 0;
    for (final med in medicines) {
      for (final schedule in med.dailySchedules) {
        if (schedule.status == AdherenceStatus.pending) count++;
      }
    }
    return count;
  }

  double get adherencePercentage {
    int total = 0;
    int taken = 0;
    for (final med in medicines) {
      for (final schedule in med.dailySchedules) {
        total++;
        if (schedule.status == AdherenceStatus.taken) taken++;
      }
    }
    if (total == 0) return 0.0;
    return taken / total;
  }

  RemindersState copyWith({
    List<MedicineReminder>? medicines,
    List<NextTestReminder>? nextTests,
    DoseTimeOfDay? selectedTimeFilter,
  }) {
    return RemindersState(
      medicines: medicines ?? this.medicines,
      nextTests: nextTests ?? this.nextTests,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
    );
  }
}


int _generateStableId(String id) {
  int hash = 0;
  for (int i = 0; i < id.length; i++) {
    hash = (31 * hash + id.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash;
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier()
      : super(RemindersState(
          medicines: SeedData.initialReminders,
          nextTests: SeedData.initialNextTests,
        )) {
    _loadState();
  }

  final _storage = const FlutterSecureStorage();

  Future<void> _saveState() async {
    try {
      final medsJson = state.medicines.map((m) => m.toJson()).toList();
      final testsJson = state.nextTests.map((t) => t.toJson()).toList();
      await _storage.write(key: 'secure_reminders_medicines', value: jsonEncode(medsJson));
      await _storage.write(key: 'secure_reminders_tests', value: jsonEncode(testsJson));
    } catch (e) {
      if (kDebugMode) debugPrint('[RemindersNotifier] Error saving state: $e');
    }
  }

  Future<void> _loadState() async {
    try {
      final medsStr = await _storage.read(key: 'secure_reminders_medicines');
      final testsStr = await _storage.read(key: 'secure_reminders_tests');
      
      List<MedicineReminder> loadedMeds = SeedData.initialReminders;
      List<NextTestReminder> loadedTests = SeedData.initialNextTests;
      
      if (medsStr != null) {
        final decodedMeds = jsonDecode(medsStr) as List;
        loadedMeds = decodedMeds.map((m) => MedicineReminder.fromJson(m)).toList();
      }
      if (testsStr != null) {
        final decodedTests = jsonDecode(testsStr) as List;
        loadedTests = decodedTests.map((t) => NextTestReminder.fromJson(t)).toList();
      }
      
      state = state.copyWith(medicines: loadedMeds, nextTests: loadedTests);
    } catch (e) {
      if (kDebugMode) debugPrint('[RemindersNotifier] Error loading state: $e');
    }
  }


  void setTimeFilter(DoseTimeOfDay filter) {
    state = state.copyWith(selectedTimeFilter: filter);
  }

  void markDoseTaken({
    required String medicineId,
    required DoseTimeOfDay timeOfDay,
  }) {
    final updatedMedicines = state.medicines.map((med) {
      if (med.id == medicineId) {
        bool wasPending = false;
        final updatedSchedules = med.dailySchedules.map((schedule) {
          if (schedule.timeOfDay == timeOfDay && schedule.status == AdherenceStatus.pending) {
            wasPending = true;

            return schedule.copyWith(
              status: AdherenceStatus.taken,
              loggedAt: DateTime.now(),
            );
          }
          return schedule;
        }).toList();

        if (wasPending) {
          final newQuantity = (med.totalQuantityAvailable - 1).clamp(0, 9999);
          final updatedMed = med.copyWith(
            dailySchedules: updatedSchedules,
            totalQuantityAvailable: newQuantity,
          );
          
          if (updatedMed.daysOfSupplyRemaining <= 3 && updatedMed.daysOfSupplyRemaining > 0) {
            NotificationService().showRefillWarning(
              id: _generateStableId(updatedMed.id),
              medicineName: updatedMed.medicineName,
              daysLeft: updatedMed.daysOfSupplyRemaining,
            );
          }
          return updatedMed;

        }
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);

    // Check for low stock warnings after taking doses for the specific medicine
    for (final med in state.lowSupplyMedicines) {
      if (med.id == medicineId && med.daysOfSupplyRemaining <= 3 && med.daysOfSupplyRemaining > 0) {
        NotificationService().showRefillWarning(
          id: _generateStableId(med.id),
          medicineName: med.medicineName,
          daysLeft: med.daysOfSupplyRemaining,
        );
      }
    }
  }

  void markAllDosesTaken(DoseTimeOfDay timeOfDay) {
    final now = DateTime.now();
    final updatedMeds = state.medicines.map((med) {
      bool changed = false;
      int pillsTaken = 0;
      final newSchedules = med.dailySchedules.map((schedule) {
        if (schedule.timeOfDay == timeOfDay &&
            schedule.status == AdherenceStatus.pending) {
          changed = true;
          pillsTaken++;
          return schedule.copyWith(
            status: AdherenceStatus.taken,
            loggedAt: now,
          );
        }
        return schedule;
      }).toList();

      if (changed) {
        final updatedMed = med.copyWith(
          dailySchedules: newSchedules,
          totalQuantityAvailable:
              (med.totalQuantityAvailable - pillsTaken).clamp(0, 9999),
        );
        
        if (updatedMed.daysOfSupplyRemaining <= 3 && updatedMed.daysOfSupplyRemaining > 0) {
          NotificationService().showRefillWarning(
            id: _generateStableId(updatedMed.id),
            medicineName: updatedMed.medicineName,
            daysLeft: updatedMed.daysOfSupplyRemaining,
          );
        }
        return updatedMed;
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMeds);

  }

  void markDoseSkipped({
    required String medicineId,
    required DoseTimeOfDay timeOfDay,
    String reason = 'Patient elected to skip',
  }) {
    final updatedMedicines = state.medicines.map((med) {
      if (med.id == medicineId) {
        final updatedSchedules = med.dailySchedules.map((schedule) {
          if (schedule.timeOfDay == timeOfDay) {
            return schedule.copyWith(
              status: AdherenceStatus.skipped,
              loggedAt: DateTime.now(),
              skipReason: reason,
            );
          }
          return schedule;
        }).toList();

        return med.copyWith(dailySchedules: updatedSchedules);
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);
  }

  void refillStock({
    required String medicineId,
    required int addedQuantity,
  }) {
    final updatedMedicines = state.medicines.map((med) {
      if (med.id == medicineId) {
        return med.copyWith(
          totalQuantityAvailable: (med.totalQuantityAvailable + addedQuantity).clamp(0, 9999),
        );
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);
  }

  void updateStock({
    required String medicineId,
    required int exactQuantity,
  }) {
    final updatedMedicines = state.medicines.map((med) {
      if (med.id == medicineId) {
        return med.copyWith(
          totalQuantityAvailable: exactQuantity.clamp(0, 9999),
        );
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);
  }

  void addMedicineReminder(MedicineReminder reminder) {
    state = state.copyWith(
      medicines: [...state.medicines, reminder],
    );

    // Schedule notification for each daily schedule
    for (int i = 0; i < reminder.dailySchedules.length; i++) {
      final schedule = reminder.dailySchedules[i];
      try {
        NotificationService().scheduleDailyMedicineReminder(
          id: _generateStableId(reminder.id) + i, // Unique int ID for local notifications
          medicineName: reminder.medicineName,
          dosage: reminder.dosage,
          timeOfDay: schedule.timeOfDay,
          timeString: schedule.timeString,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Failed to schedule medicine reminder: $e');

      }
    }
  
  }


  void addNextTestReminder(NextTestReminder reminder) {
    state = state.copyWith(nextTests: [reminder, ...state.nextTests]);
    
    try {
      NotificationService().scheduleTestReminder(
        id: _generateStableId(reminder.id),
        testName: reminder.testName,
        labName: reminder.labOrClinicName,
        date: reminder.scheduledDate,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to schedule test reminder: $e');

    }
  }

  void markNextTestCompleted(String id) {
    final updatedTests = state.nextTests.map((t) {
      if (t.id == id) {
        return NextTestReminder(
          id: t.id,
          testName: t.testName,
          labOrClinicName: t.labOrClinicName,
          scheduledDate: t.scheduledDate,
          preparationInstructions: t.preparationInstructions,
          isCompleted: true,
          relatedReportId: t.relatedReportId,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(nextTests: updatedTests);
    
    try {
      NotificationService().cancelNotification(_generateStableId(id));
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to cancel completed test notification: $e');
    }
  }

  void deleteMedicine(String medicineId) {
    final medIndex = state.medicines.indexWhere((m) => m.id == medicineId);
    if (medIndex != -1) {
      final med = state.medicines[medIndex];
      for (int i = 0; i < med.dailySchedules.length; i++) {
        try {
          NotificationService().cancelNotification(_generateStableId(med.id) + i);
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to cancel medicine notification: $e');
        }
      }
      
      final updatedMedicines = List<MedicineReminder>.from(state.medicines)..removeAt(medIndex);
      state = state.copyWith(medicines: updatedMedicines);
    }
  }

  void deleteTest(String testId) {
    try {
      NotificationService().cancelNotification(_generateStableId(testId));
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to cancel test notification: $e');
    }

    final updatedTests = state.nextTests.where((t) => t.id != testId).toList();
    state = state.copyWith(nextTests: updatedTests);

  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier();
});
