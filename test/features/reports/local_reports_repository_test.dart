import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistacortex_new_features/features/reports/data/local_reports_repository.dart';
import 'package:vistacortex_new_features/features/reports/data/report_file_service.dart';
import 'package:vistacortex_new_features/features/reports/models/report_model.dart';
import 'package:vistacortex_new_features/features/reports/models/report_upload_policy.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    temporaryDirectory =
        await Directory.systemTemp.createTemp('vistacortex_reports_test_');
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('starts with a clean report list', () async {
    final repository = LocalReportsRepository(
      fileService: ReportFileService(
        documentsDirectory: () async => temporaryDirectory,
      ),
    );

    expect(await repository.loadReports(), isEmpty);
  });

  test('removes legacy demo reports while preserving imported reports',
      () async {
    final demoReport = _report(id: 'rep_001', title: 'Old demo report');
    final importedReport = _report(
      id: 'report_user_upload',
      title: 'My uploaded report',
    );
    SharedPreferences.setMockInitialValues({
      'medical_reports_v2': jsonEncode([
        demoReport.toJson(),
        importedReport.toJson(),
      ]),
    });
    final repository = LocalReportsRepository(
      fileService: ReportFileService(
        documentsDirectory: () async => temporaryDirectory,
      ),
    );

    final reports = await repository.loadReports();

    expect(reports, hasLength(1));
    expect(reports.single.id, 'report_user_upload');
    expect(await repository.loadReports(), hasLength(1));
  });

  test('copies a document and persists report metadata across instances',
      () async {
    final source = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}source.pdf',
    );
    await source.writeAsBytes(const [37, 80, 68, 70, 45, 49, 46, 52]);
    final documentsDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}documents',
    );
    final fileService = ReportFileService(
      documentsDirectory: () async => documentsDirectory,
    );
    final repository = LocalReportsRepository(fileService: fileService);

    final storedPath = await repository.storeDocument(
      sourcePath: source.path,
      originalFileName: 'blood-test.pdf',
    );
    expect(await File(storedPath).exists(), isTrue);

    final report = MedicalReport(
      id: 'persisted-1',
      title: 'Blood Test',
      category: ReportCategory.bloodTest,
      labProvider: 'Test Lab',
      doctorName: 'Not specified',
      reportDate: DateTime(2026, 9, 16),
      pdfAssetPath: storedPath,
      documentType: ReportDocumentType.pdf,
      originalFileName: 'blood-test.pdf',
      summaryPlainLanguage: 'Stored',
      questionsForDoctor: const [],
      parameters: const [],
    );
    await repository.saveReports([report]);

    final reloaded = await LocalReportsRepository(
      fileService: fileService,
    ).loadReports();
    expect(reloaded.single.title, 'Blood Test');
    expect(reloaded.single.pdfAssetPath, storedPath);

    await repository.deleteDocument(report);
    expect(await File(storedPath).exists(), isFalse);
  });

  test('rejects a report that exceeds the configured per-file limit', () async {
    final source = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}oversized.pdf',
    );
    await source.writeAsBytes(List<int>.filled(9, 1));
    final fileService = ReportFileService(
      documentsDirectory: () async => Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}documents',
      ),
      maxFileSizeBytes: 8,
    );

    expect(
      () => fileService.copyIntoVault(
        sourcePath: source.path,
        originalFileName: 'oversized.pdf',
      ),
      throwsA(isA<ReportFileTooLargeException>()),
    );
  });

  test('rejects a report when the private report vault is full', () async {
    final source = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}second.pdf',
    );
    await source.writeAsBytes(List<int>.filled(6, 1));
    final documentsDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}documents',
    );
    final vault = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}medical_reports',
    );
    await vault.create(recursive: true);
    await File('${vault.path}${Platform.pathSeparator}first.pdf')
        .writeAsBytes(List<int>.filled(5, 1));
    final fileService = ReportFileService(
      documentsDirectory: () async => documentsDirectory,
      maxFileSizeBytes: 10,
      maxVaultSizeBytes: 10,
    );

    expect(
      () => fileService.copyIntoVault(
        sourcePath: source.path,
        originalFileName: 'second.pdf',
      ),
      throwsA(isA<ReportVaultFullException>()),
    );
  });
}

MedicalReport _report({required String id, required String title}) =>
    MedicalReport(
      id: id,
      title: title,
      category: ReportCategory.generalCheckup,
      labProvider: 'Test Lab',
      doctorName: 'Not specified',
      reportDate: DateTime(2026, 9, 20),
      pdfAssetPath: '',
      summaryPlainLanguage: '',
      questionsForDoctor: const [],
      parameters: const [],
    );
