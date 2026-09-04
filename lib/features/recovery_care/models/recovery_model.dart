enum CareTaskCategory {
  medication,
  woundDressing,
  mobilityExercise,
  vitalsCheck,
  hydrationDiet,
  restMilestone,
}

class DailyCareTask {
  final String id;
  final String title;
  final String description;
  final String timeOfDay;
  final CareTaskCategory category;
  final bool isCompleted;
  final DateTime? completedAt;

  DailyCareTask({
    required this.id,
    required this.title,
    required this.description,
    required this.timeOfDay,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  DailyCareTask copyWith({bool? isCompleted, DateTime? completedAt}) {
    return DailyCareTask(
      id: id,
      title: title,
      description: description,
      timeOfDay: timeOfDay,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class RecoveryCarePlan {
  final String id;
  final String procedureName; // e.g. "Post-Laparoscopic Cholecystectomy"
  final String operatingSurgeon;
  final String hospitalName;
  final DateTime surgeryDate;
  final int totalRecoveryDays;
  final int currentDay;
  final List<String> clinicalPrecautions;
  final List<DailyCareTask> todayTasks;
  final int painLevelScore; // 1 to 10

  RecoveryCarePlan({
    required this.id,
    required this.procedureName,
    required this.operatingSurgeon,
    required this.hospitalName,
    required this.surgeryDate,
    required this.totalRecoveryDays,
    required this.currentDay,
    required this.clinicalPrecautions,
    required this.todayTasks,
    this.painLevelScore = 2,
  });

  double get progressFraction => (currentDay / totalRecoveryDays).clamp(0.0, 1.0);

  RecoveryCarePlan copyWith({
    List<DailyCareTask>? todayTasks,
    int? painLevelScore,
  }) {
    return RecoveryCarePlan(
      id: id,
      procedureName: procedureName,
      operatingSurgeon: operatingSurgeon,
      hospitalName: hospitalName,
      surgeryDate: surgeryDate,
      totalRecoveryDays: totalRecoveryDays,
      currentDay: currentDay,
      clinicalPrecautions: clinicalPrecautions,
      todayTasks: todayTasks ?? this.todayTasks,
      painLevelScore: painLevelScore ?? this.painLevelScore,
    );
  }
}

class MealGuidance {
  final String mealType; // Breakfast, Lunch, Snack, Dinner
  final String recommendedFood;
  final String benefits;
  final String caloriesAndNutrients;
  final List<String> avoidFoods;

  MealGuidance({
    required this.mealType,
    required this.recommendedFood,
    required this.benefits,
    required this.caloriesAndNutrients,
    required this.avoidFoods,
  });
}

class PatientDietPlan {
  final String planTitle;
  final String conditionContext; // e.g. "Low Sodium & Glycemic Control"
  final String generalGuidance;
  final List<MealGuidance> dailyMeals;
  final List<String> foodDrugInteractions;

  PatientDietPlan({
    required this.planTitle,
    required this.conditionContext,
    required this.generalGuidance,
    required this.dailyMeals,
    required this.foodDrugInteractions,
  });
}
