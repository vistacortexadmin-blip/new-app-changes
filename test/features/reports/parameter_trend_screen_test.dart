import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vistacortex_new_features/features/reports/data/reports_repository.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/providers/reports_provider.dart';
import 'package:vistacortex_new_features/features/reports/views/parameter_trend_screen.dart';

void main() {
  testWidgets('renders a graphical trendline from historical reports',
      (tester) async {
    final repository = _TrendReportsRepository([
      _report('first', DateTime(2026, 7, 1), 6.4),
      _report('second', DateTime(2026, 9, 1), 5.9),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: ParameterTrendScreen(parameterName: 'HbA1c'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('parameter-trend-chart')), findsOneWidget);
    expect(find.text('Biomarker trendline'), findsOneWidget);
    expect(find.textContaining('Decreased from 6.4'), findsOneWidget);
    expect(find.text('01 July 2026'), findsOneWidget);
    expect(find.text('01 September 2026'), findsOneWidget);
  });
}

MedicalReport _report(String id, DateTime date, double value) => MedicalReport(
      id: id,
      title: 'HbA1c report $id',
      category: ReportCategory.diabeticPanel,
      labProvider: 'Vista Lab',
      doctorName: 'Dr Test',
      reportDate: date,
      pdfAssetPath: '',
      summaryPlainLanguage: 'Extracted result',
      questionsForDoctor: const [],
      parameters: [
        TestParameter(
          id: 'hba1c',
          name: 'HbA1c',
          value: value,
          unit: '%',
          minNormal: 4,
          maxNormal: 5.6,
        ),
      ],
      analysisStatus: ReportAnalysisStatus.completed,
    );

class _TrendReportsRepository implements ReportsRepository {
  final List<MedicalReport> reports;

  const _TrendReportsRepository(this.reports);

  @override
  Future<List<MedicalReport>> loadReports() async => reports;

  @override
  Future<void> saveReports(List<MedicalReport> reports) async {}

  @override
  Future<String> storeDocument({
    required String sourcePath,
    required String originalFileName,
  }) async =>
      sourcePath;

  @override
  Future<void> deleteDocument(MedicalReport report) async {}
}
