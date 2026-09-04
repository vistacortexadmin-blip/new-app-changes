import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../../../core/storage/seed_data.dart';

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

class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier()
      : super(RemindersState(
          medicines: SeedData.initialReminders,
          nextTests: SeedData.initialNextTests,
        ));

  void setTimeFilter(DoseTimeOfDay filter) {
    state = state.copyWith(selectedTimeFilter: filter);
  }

  void markDoseTaken({
    required String medicineId,
    required DoseTimeOfDay timeOfDay,
  }) {
    final updatedMedicines = state.medicines.map((med) {
      if (med.id == medicineId) {
        final updatedSchedules = med.dailySchedules.map((schedule) {
          if (schedule.timeOfDay == timeOfDay) {
            return schedule.copyWith(
              status: AdherenceStatus.taken,
              loggedAt: DateTime.now(),
            );
          }
          return schedule;
        }).toList();

        // Decrement 1 pill from quantity count
        final newQuantity = (med.totalQuantityAvailable - 1).clamp(0, 999);
        return med.copyWith(
          dailySchedules: updatedSchedules,
          totalQuantityAvailable: newQuantity,
        );
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);
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
          totalQuantityAvailable: med.totalQuantityAvailable + addedQuantity,
        );
      }
      return med;
    }).toList();

    state = state.copyWith(medicines: updatedMedicines);
  }

  void addNextTestReminder(NextTestReminder reminder) {
    state = state.copyWith(nextTests: [reminder, ...state.nextTests]);
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
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier();
});
