import 'package:flutter_test/flutter_test.dart';
import 'package:vistacortex_new_features/features/reports/data/reports_repository.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/models/report_upload_policy.dart';
import 'package:vistacortex_new_features/features/reports/providers/reports_provider.dart';
import 'package:vistacortex_new_features/features/reports/services/report_analysis_service.dart';

void main() {
  late _FakeReportsRepository repository;
  late ReportsNotifier notifier;

  setUp(() {
    repository = _FakeReportsRepository([_seedReport()]);
    notifier = ReportsNotifier(
      repository,
      analysisService: _FakeAnalysisService(),
      autoLoad: false,
    );
  });

  tearDown(() => notifier.dispose());

  test('loads, searches and filters repository reports', () async {
    await notifier.initialize();
    expect(notifier.state.reports, hasLength(1));

    notifier.setSearchQuery('vista lab');
    expect(notifier.state.filteredReports, hasLength(1));

    notifier.setCategoryFilter(ReportCategory.radiology);
    expect(notifier.state.filteredReports, isEmpty);

    notifier.setCategoryFilter(ReportCategory.radiology);
    expect(notifier.state.selectedCategory, isNull);
  });

  test('imports, persists and deletes a report document', () async {
    await notifier.initialize();
    final imported = await notifier.importReport(
      ReportImportDraft(
        sourcePath: '/incoming/hba1c.pdf',
        originalFileName: 'hba1c.pdf',
        documentType: ReportDocumentType.pdf,
        title: 'HbA1c Report',
        category: ReportCategory.diabeticPanel,
        labProvider: 'Health Lab',
        doctorName: '',
        reportDate: DateTime(2026, 9, 15),
      ),
    );

    expect(imported, isNotNull);
    expect(notifier.state.reports, hasLength(2));
    expect(notifier.state.reports.first.pdfAssetPath, '/vault/hba1c.pdf');
    expect(
      notifier.state.reports.first.effectiveDietPlan?.title,
      contains('findings'),
    );
    expect(
      notifier.state.reports.first.analysisStatus,
      ReportAnalysisStatus.completed,
    );
    expect(repository.savedReports, hasLength(2));

    final deleted = await notifier.deleteReport(imported!.id);
    expect(deleted, isTrue);
    expect(notifier.state.reports, hasLength(1));
    expect(repository.deletedPaths, contains('/vault/hba1c.pdf'));
  });

  test('shows a helpful error when a selected report is too large', () async {
    await notifier.initialize();
    repository.storeError = const ReportFileTooLargeException(11 * 1024 * 1024);

    final imported = await notifier.importReport(
      ReportImportDraft(
        sourcePath: '/incoming/large.pdf',
        originalFileName: 'large.pdf',
        documentType: ReportDocumentType.pdf,
        title: 'Large Report',
        category: ReportCategory.generalCheckup,
        labProvider: 'Health Lab',
        doctorName: '',
        reportDate: DateTime(2026, 9, 16),
      ),
    );

    expect(imported, isNull);
    expect(notifier.state.errorMessage, contains('10 MB'));
    expect(notifier.state.isUploading, isFalse);
  });
}

MedicalReport _seedReport() => MedicalReport(
      id: 'seed-1',
      title: 'Complete Blood Count',
      category: ReportCategory.bloodTest,
      labProvider: 'Vista Lab',
      doctorName: 'Dr A',
      reportDate: DateTime(2026, 9, 1),
      pdfAssetPath: '',
      summaryPlainLanguage: 'Normal CBC',
      questionsForDoctor: const [],
      parameters: const [],
    );

class _FakeReportsRepository implements ReportsRepository {
  _FakeReportsRepository(this.savedReports);

  List<MedicalReport> savedReports;
  final List<String> deletedPaths = [];
  Object? storeError;

  @override
  Future<List<MedicalReport>> loadReports() async => [...savedReports];

  @override
  Future<void> saveReports(List<MedicalReport> reports) async {
    savedReports = [...reports];
  }

  @override
  Future<String> storeDocument({
    required String sourcePath,
    required String originalFileName,
  }) async {
    if (storeError != null) throw storeError!;
    return '/vault/$originalFileName';
  }

  @override
  Future<void> deleteDocument(MedicalReport report) async {
    deletedPaths.add(report.pdfAssetPath);
  }
}

class _FakeAnalysisService implements ReportAnalysisService {
  @override
  Future<ReportAnalysisResult> analyzeDocument({
    required String documentPath,
    required ReportDocumentType documentType,
    required ReportCategory category,
  }) async =>
      ReportAnalysisResult(
        parameters: [
          TestParameter(
            id: 'glucose',
            name: 'Fasting Blood Glucose',
            value: 108,
            unit: 'mg/dL',
            minNormal: 70,
            maxNormal: 99,
          ),
        ],
        summary: 'One extracted value needs review.',
        questionsForDoctor: const ['Should this be repeated?'],
        dietRecommendation: const DietRecommendation(
          title: 'Nutrition priorities from findings',
          rationale: 'Generated from extracted glucose.',
          foodsToEat: ['Vegetables'],
          foodsToAvoid: ['Sugary drinks'],
          dailyMeals: [],
          nutritionTip: 'Confirm with a clinician.',
        ),
        status: ReportAnalysisStatus.completed,
      );
}
