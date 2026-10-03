import 'package:flutter_test/flutter_test.dart';
import 'package:vistacortex_new_features/core/utils/trend_calculator.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/services/report_analysis_service.dart';

void main() {
  const engine = BiomarkerAnalysisEngine();

  test('extracts biomarkers and generates finding-based guidance', () {
    const reportText = '''
Hemoglobin 13.8 12.0 - 16.0 g/dL
Fasting Blood Glucose 108 70 - 99 mg/dL
HbA1c 5.9 4.0 - 5.6 %
Total Cholesterol 212 125 - 200 mg/dL
LDL Cholesterol 137 0 - 100 mg/dL
HDL Cholesterol 52 40 - 100 mg/dL
Triglycerides 116 0 - 150 mg/dL
Creatinine 0.86 0.60 - 1.10 mg/dL
eGFR 96 60 - 150 mL/min
Sodium 140 136 - 145 mmol/L
Potassium 4.2 3.5 - 5.1 mmol/L
''';

    final result = engine.analyzeText(
      reportText,
      category: ReportCategory.generalCheckup,
    );

    expect(result.status, ReportAnalysisStatus.completed);
    expect(result.parameters.length, greaterThanOrEqualTo(10));
    final glucose = result.parameters.firstWhere(
      (parameter) => parameter.name == 'Fasting Glucose',
    );
    expect(glucose.value, 108);
    expect(glucose.status, ValueStatus.high);
    expect(result.summary, contains('outside'));
    expect(result.questionsForDoctor, isNotEmpty);
    expect(result.dietRecommendation, isNotNull);
    expect(
      result.dietRecommendation!.foodsToAvoid.join(' ').toLowerCase(),
      contains('sugary'),
    );
    expect(
      result.dietRecommendation!.rationale.toLowerCase(),
      contains('lipid'),
    );
  });

  test('does not fabricate values or a diet plan when no biomarkers exist', () {
    final result = engine.analyzeText(
      'Patient name and appointment details only.',
      category: ReportCategory.generalCheckup,
    );

    expect(result.status, ReportAnalysisStatus.noValuesFound);
    expect(result.parameters, isEmpty);
    expect(result.dietRecommendation, isNull);
  });

  test('uses directional critical labels', () {
    expect(
      TrendCalculator.evaluateStatus(20, 70, 100),
      ValueStatus.criticalLow,
    );
    expect(
      TrendCalculator.getStatusLabel(ValueStatus.criticalLow),
      'Critical Low',
    );
    expect(
      TrendCalculator.evaluateStatus(160, 70, 100),
      ValueStatus.criticalHigh,
    );
    expect(
      TrendCalculator.getStatusLabel(ValueStatus.criticalHigh),
      'Critical High',
    );
  });
}
