import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/views/report_details_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('diet tabs display different report-specific content',
      (tester) async {
    final report = MedicalReport(
      id: 'detail-1',
      title: 'CBC Report',
      category: ReportCategory.bloodTest,
      labProvider: 'Vista Lab',
      doctorName: 'Dr A',
      reportDate: DateTime(2026, 9, 16),
      pdfAssetPath: '',
      summaryPlainLanguage: 'Summary',
      questionsForDoctor: const [],
      parameters: const [],
      analysisStatus: ReportAnalysisStatus.completed,
      dietRecommendation: const DietRecommendation(
        title: 'Report-linked nutrition plan',
        rationale: 'Generated from extracted hemoglobin.',
        foodsToEat: ['Spinach, lentils and chickpeas'],
        foodsToAvoid: ['Tea with iron-rich meals'],
        dailyMeals: [
          DietMeal(
            mealType: 'Breakfast',
            recommendedFood: 'Vegetable poha with peanuts and one orange',
            benefits: 'Vitamin C supports iron absorption.',
            nutrition: 'Iron and vitamin C',
          ),
        ],
        nutritionTip: 'Confirm the plan with your clinician.',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ReportDetailsScreen(report: report)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CBC Report'), findsWidgets);
    await tester.tap(find.text('Diet Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Vegetable poha with peanuts and one orange'),
        findsOneWidget);

    await tester.tap(
      find.byKey(const Key('diet-filter-Foods to Include')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Spinach, lentils and chickpeas'), findsOneWidget);
    expect(
        find.text('Vegetable poha with peanuts and one orange'), findsNothing);
  });
}
