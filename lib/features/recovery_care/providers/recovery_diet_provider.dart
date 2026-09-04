import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recovery_model.dart';
import '../../../core/storage/seed_data.dart';

class RecoveryDietState {
  final RecoveryCarePlan recoveryPlan;
  final PatientDietPlan dietPlan;
  final bool showDietTab;

  RecoveryDietState({
    required this.recoveryPlan,
    required this.dietPlan,
    this.showDietTab = false,
  });

  int get completedTasksCount =>
      recoveryPlan.todayTasks.where((t) => t.isCompleted).length;

  int get totalTasksCount => recoveryPlan.todayTasks.length;

  double get dailyTaskProgress =>
      totalTasksCount == 0 ? 0.0 : (completedTasksCount / totalTasksCount);

  RecoveryDietState copyWith({
    RecoveryCarePlan? recoveryPlan,
    PatientDietPlan? dietPlan,
    bool? showDietTab,
  }) {
    return RecoveryDietState(
      recoveryPlan: recoveryPlan ?? this.recoveryPlan,
      dietPlan: dietPlan ?? this.dietPlan,
      showDietTab: showDietTab ?? this.showDietTab,
    );
  }
}

class RecoveryDietNotifier extends StateNotifier<RecoveryDietState> {
  RecoveryDietNotifier()
      : super(RecoveryDietState(
          recoveryPlan: SeedData.initialRecoveryPlan,
          dietPlan: SeedData.initialDietPlan,
        ));

  void toggleTaskCompletion(String taskId) {
    final updatedTasks = state.recoveryPlan.todayTasks.map((task) {
      if (task.id == taskId) {
        final newStatus = !task.isCompleted;
        return task.copyWith(
          isCompleted: newStatus,
          completedAt: newStatus ? DateTime.now() : null,
        );
      }
      return task;
    }).toList();

    state = state.copyWith(
      recoveryPlan: state.recoveryPlan.copyWith(todayTasks: updatedTasks),
    );
  }

  void updatePainScore(int score) {
    state = state.copyWith(
      recoveryPlan: state.recoveryPlan.copyWith(painLevelScore: score),
    );
  }

  void setViewTab(bool isDietTab) {
    state = state.copyWith(showDietTab: isDietTab);
  }
}

final recoveryDietProvider =
    StateNotifierProvider<RecoveryDietNotifier, RecoveryDietState>((ref) {
  return RecoveryDietNotifier();
});
