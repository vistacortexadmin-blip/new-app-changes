import '../../../core/utils/trend_calculator.dart';

class TestParameter {
  final String id;
  final String name;
  final double value;
  final String unit;
  final double minNormal;
  final double maxNormal;
  final String? interpretation;
  final ValueStatus status;

  TestParameter({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.minNormal,
    required this.maxNormal,
    this.interpretation,
    ValueStatus? status,
  }) : status = status ??
            TrendCalculator.evaluateStatus(value, minNormal, maxNormal);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'unit': unit,
        'minNormal': minNormal,
        'maxNormal': maxNormal,
        'interpretation': interpretation,
        'status': status.name,
      };

  factory TestParameter.fromJson(Map<String, dynamic> json) => TestParameter(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        value: (json['value'] as num? ?? 0).toDouble(),
        unit: json['unit'] as String? ?? '',
        minNormal: (json['minNormal'] as num? ?? 0).toDouble(),
        maxNormal: (json['maxNormal'] as num? ?? 0).toDouble(),
        interpretation: json['interpretation'] as String?,
      );
}

enum ReportCategory {
  bloodTest,
  lipidProfile,
  diabeticPanel,
  cardiology,
  radiology,
  urineAnalysis,
  generalCheckup,
}

enum ReportDocumentType { none, pdf, image }

enum ReportAnalysisStatus {
  notStarted,
  completed,
  noValuesFound,
  failed,
}

class DietMeal {
  final String mealType;
  final String recommendedFood;
  final String benefits;
  final String nutrition;

  const DietMeal({
    required this.mealType,
    required this.recommendedFood,
    required this.benefits,
    required this.nutrition,
  });

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'recommendedFood': recommendedFood,
        'benefits': benefits,
        'nutrition': nutrition,
      };

  factory DietMeal.fromJson(Map<String, dynamic> json) => DietMeal(
        mealType: json['mealType'] as String? ?? '',
        recommendedFood: json['recommendedFood'] as String? ?? '',
        benefits: json['benefits'] as String? ?? '',
        nutrition: json['nutrition'] as String? ?? '',
      );
}

class DietRecommendation {
  final String title;
  final String rationale;
  final List<String> foodsToEat;
  final List<String> foodsToAvoid;
  final List<DietMeal> dailyMeals;
  final String nutritionTip;

  const DietRecommendation({
    required this.title,
    required this.rationale,
    required this.foodsToEat,
    required this.foodsToAvoid,
    required this.dailyMeals,
    required this.nutritionTip,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'rationale': rationale,
        'foodsToEat': foodsToEat,
        'foodsToAvoid': foodsToAvoid,
        'dailyMeals': dailyMeals.map((meal) => meal.toJson()).toList(),
        'nutritionTip': nutritionTip,
      };

  factory DietRecommendation.fromJson(Map<String, dynamic> json) =>
      DietRecommendation(
        title: json['title'] as String? ?? 'Report-linked nutrition guidance',
        rationale: json['rationale'] as String? ?? '',
        foodsToEat: List<String>.from(json['foodsToEat'] as List? ?? const []),
        foodsToAvoid:
            List<String>.from(json['foodsToAvoid'] as List? ?? const []),
        dailyMeals: (json['dailyMeals'] as List? ?? const [])
            .whereType<Map>()
            .map((meal) => DietMeal.fromJson(Map<String, dynamic>.from(meal)))
            .toList(),
        nutritionTip: json['nutritionTip'] as String? ?? '',
      );
}

class MedicalReport {
  final String id;
  final String title;
  final ReportCategory category;
  final String labProvider;
  final String doctorName;
  final DateTime reportDate;
  final String pdfAssetPath;
  final ReportDocumentType documentType;
  final String? originalFileName;
  final DateTime createdAt;
  final String summaryPlainLanguage;
  final List<String> questionsForDoctor;
  final List<TestParameter> parameters;
  final DietRecommendation? dietRecommendation;
  final ReportAnalysisStatus analysisStatus;
  final DateTime? analyzedAt;
  final bool isFlagged;

  MedicalReport({
    required this.id,
    required this.title,
    required this.category,
    required this.labProvider,
    required this.doctorName,
    required this.reportDate,
    required this.pdfAssetPath,
    this.documentType = ReportDocumentType.none,
    this.originalFileName,
    DateTime? createdAt,
    required this.summaryPlainLanguage,
    required this.questionsForDoctor,
    required this.parameters,
    this.dietRecommendation,
    this.analysisStatus = ReportAnalysisStatus.notStarted,
    this.analyzedAt,
    this.isFlagged = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasDocument => pdfAssetPath.trim().isNotEmpty;
  bool get hasAnalysis =>
      analysisStatus == ReportAnalysisStatus.completed && parameters.isNotEmpty;
  DietRecommendation? get effectiveDietPlan => dietRecommendation;

  String get categoryDisplayName {
    switch (category) {
      case ReportCategory.bloodTest:
        return 'Complete Blood Count';
      case ReportCategory.lipidProfile:
        return 'Lipid & Cholesterol';
      case ReportCategory.diabeticPanel:
        return 'HbA1c & Glucose';
      case ReportCategory.cardiology:
        return 'Cardiology ECG/Echo';
      case ReportCategory.radiology:
        return 'X-Ray & Radiology';
      case ReportCategory.urineAnalysis:
        return 'Urinalysis Routine';
      case ReportCategory.generalCheckup:
        return 'Comprehensive Health';
    }
  }

  MedicalReport copyWith({
    String? title,
    ReportCategory? category,
    String? labProvider,
    String? doctorName,
    DateTime? reportDate,
    String? pdfAssetPath,
    ReportDocumentType? documentType,
    String? originalFileName,
    DateTime? createdAt,
    String? summaryPlainLanguage,
    List<String>? questionsForDoctor,
    List<TestParameter>? parameters,
    DietRecommendation? dietRecommendation,
    bool clearDietRecommendation = false,
    ReportAnalysisStatus? analysisStatus,
    DateTime? analyzedAt,
    bool clearAnalyzedAt = false,
    bool? isFlagged,
  }) =>
      MedicalReport(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        labProvider: labProvider ?? this.labProvider,
        doctorName: doctorName ?? this.doctorName,
        reportDate: reportDate ?? this.reportDate,
        pdfAssetPath: pdfAssetPath ?? this.pdfAssetPath,
        documentType: documentType ?? this.documentType,
        originalFileName: originalFileName ?? this.originalFileName,
        createdAt: createdAt ?? this.createdAt,
        summaryPlainLanguage: summaryPlainLanguage ?? this.summaryPlainLanguage,
        questionsForDoctor: questionsForDoctor ?? this.questionsForDoctor,
        parameters: parameters ?? this.parameters,
        dietRecommendation: clearDietRecommendation
            ? null
            : (dietRecommendation ?? this.dietRecommendation),
        analysisStatus: analysisStatus ?? this.analysisStatus,
        analyzedAt: clearAnalyzedAt ? null : (analyzedAt ?? this.analyzedAt),
        isFlagged: isFlagged ?? this.isFlagged,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'labProvider': labProvider,
        'doctorName': doctorName,
        'reportDate': reportDate.toIso8601String(),
        'pdfAssetPath': pdfAssetPath,
        'documentType': documentType.name,
        'originalFileName': originalFileName,
        'createdAt': createdAt.toIso8601String(),
        'summaryPlainLanguage': summaryPlainLanguage,
        'questionsForDoctor': questionsForDoctor,
        'parameters': parameters.map((item) => item.toJson()).toList(),
        'dietRecommendation': dietRecommendation?.toJson(),
        'analysisStatus': analysisStatus.name,
        'analyzedAt': analyzedAt?.toIso8601String(),
        'isFlagged': isFlagged,
      };

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    T enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.firstWhere(
          (value) => value.name == raw?.toString(),
          orElse: () => fallback,
        );

    final dietJson = json['dietRecommendation'];
    final parameters = (json['parameters'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => TestParameter.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final storedStatus = enumByName(
      ReportAnalysisStatus.values,
      json['analysisStatus'],
      parameters.isEmpty
          ? ReportAnalysisStatus.notStarted
          : ReportAnalysisStatus.completed,
    );
    return MedicalReport(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Medical report',
      category: enumByName(
        ReportCategory.values,
        json['category'],
        ReportCategory.generalCheckup,
      ),
      labProvider: json['labProvider'] as String? ?? 'Unknown provider',
      doctorName: json['doctorName'] as String? ?? 'Not specified',
      reportDate: DateTime.tryParse(json['reportDate'] as String? ?? '') ??
          DateTime.now(),
      pdfAssetPath: json['pdfAssetPath'] as String? ?? '',
      documentType: enumByName(
        ReportDocumentType.values,
        json['documentType'],
        ReportDocumentType.none,
      ),
      originalFileName: json['originalFileName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      summaryPlainLanguage: json['summaryPlainLanguage'] as String? ?? '',
      questionsForDoctor:
          List<String>.from(json['questionsForDoctor'] as List? ?? const []),
      parameters: parameters,
      dietRecommendation: dietJson is Map
          ? DietRecommendation.fromJson(Map<String, dynamic>.from(dietJson))
          : null,
      analysisStatus: storedStatus,
      analyzedAt: DateTime.tryParse(json['analyzedAt'] as String? ?? ''),
      isFlagged: json['isFlagged'] as bool? ?? false,
    );
  }
}
