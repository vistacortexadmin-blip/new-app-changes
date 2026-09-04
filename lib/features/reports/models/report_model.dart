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
  }) : status = status ?? TrendCalculator.evaluateStatus(value, minNormal, maxNormal);

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
        id: json['id'],
        name: json['name'],
        value: (json['value'] as num).toDouble(),
        unit: json['unit'],
        minNormal: (json['minNormal'] as num).toDouble(),
        maxNormal: (json['maxNormal'] as num).toDouble(),
        interpretation: json['interpretation'],
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

class MedicalReport {
  final String id;
  final String title;
  final ReportCategory category;
  final String labProvider;
  final String doctorName;
  final DateTime reportDate;
  final String pdfAssetPath;
  final String summaryPlainLanguage;
  final List<String> questionsForDoctor;
  final List<TestParameter> parameters;
  final bool isFlagged;

  MedicalReport({
    required this.id,
    required this.title,
    required this.category,
    required this.labProvider,
    required this.doctorName,
    required this.reportDate,
    required this.pdfAssetPath,
    required this.summaryPlainLanguage,
    required this.questionsForDoctor,
    required this.parameters,
    this.isFlagged = false,
  });

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
}
