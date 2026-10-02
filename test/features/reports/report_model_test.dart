import 'package:flutter_test/flutter_test.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';

void main() {
  test('MedicalReport serializes document and diet data', () {
    final report = MedicalReport(
      id: 'report-1',
      title: 'CBC Report',
      category: ReportCategory.bloodTest,
      labProvider: 'Vista Lab',
      doctorName: 'Dr Test',
      reportDate: DateTime(2026, 9, 16),
      pdfAssetPath: '/vault/cbc.pdf',
      documentType: ReportDocumentType.pdf,
      originalFileName: 'cbc.pdf',
      createdAt: DateTime(2026, 9, 16, 10),
      summaryPlainLanguage: 'Stored report',
      questionsForDoctor: const ['Any follow-up?'],
      parameters: [
        TestParameter(
          id: 'hemoglobin',
          name: 'Hemoglobin',
          value: 14,
          unit: 'g/dL',
          minNormal: 13,
          maxNormal: 17,
        ),
      ],
      dietRecommendation: _dietRecommendation(),
      analysisStatus: ReportAnalysisStatus.completed,
      analyzedAt: DateTime(2026, 9, 16, 10, 5),
    );

    final restored = MedicalReport.fromJson(report.toJson());

    expect(restored.id, report.id);
    expect(restored.title, report.title);
    expect(restored.documentType, ReportDocumentType.pdf);
    expect(restored.originalFileName, 'cbc.pdf');
    expect(restored.parameters.single.name, 'Hemoglobin');
    expect(restored.effectiveDietPlan?.foodsToEat, isNotEmpty);
    expect(restored.effectiveDietPlan?.dailyMeals, hasLength(1));
    expect(restored.analysisStatus, ReportAnalysisStatus.completed);
  });

  test('a report without analysis has no preset diet plan', () {
    final report = MedicalReport(
      id: 'fresh',
      title: 'Fresh report',
      category: ReportCategory.diabeticPanel,
      labProvider: 'Vista Lab',
      doctorName: 'Not specified',
      reportDate: DateTime(2026, 9, 16),
      pdfAssetPath: '/vault/fresh.pdf',
      summaryPlainLanguage: '',
      questionsForDoctor: const [],
      parameters: const [],
    );

    expect(report.effectiveDietPlan, isNull);
    expect(report.analysisStatus, ReportAnalysisStatus.notStarted);
  });
}

DietRecommendation _dietRecommendation() => const DietRecommendation(
      title: 'Finding-based plan',
      rationale: 'Generated from extracted findings.',
      foodsToEat: ['Lentils'],
      foodsToAvoid: ['Sugary drinks'],
      dailyMeals: [
        DietMeal(
          mealType: 'Lunch',
          recommendedFood: 'Dal and vegetables',
          benefits: 'Fiber and protein',
          nutrition: 'Balanced meal',
        ),
      ],
      nutritionTip: 'Confirm with your clinician.',
    );
