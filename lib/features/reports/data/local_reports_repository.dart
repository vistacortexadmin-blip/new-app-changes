import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/report_model.dart';
import 'report_file_service.dart';
import 'reports_repository.dart';

class LocalReportsRepository implements ReportsRepository {
  static const _storageKey = 'medical_reports_v2';
  static const _legacyDemoReportIds = {'rep_001', 'rep_002', 'rep_003'};

  final Future<SharedPreferences> Function() _preferences;
  final ReportFileService _fileService;

  LocalReportsRepository({
    Future<SharedPreferences> Function()? preferences,
    ReportFileService? fileService,
  })  : _preferences = preferences ?? SharedPreferences.getInstance,
        _fileService = fileService ?? ReportFileService();

  @override
  Future<List<MedicalReport>> loadReports() async {
    final preferences = await _preferences();
    final storedJson = preferences.getString(_storageKey);
    if (storedJson == null || storedJson.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedJson);
      if (decoded is! List) throw const FormatException('Invalid report list');
      final reports = decoded
          .whereType<Map>()
          .map(
              (item) => MedicalReport.fromJson(Map<String, dynamic>.from(item)))
          .where((report) => !_legacyDemoReportIds.contains(report.id))
          .toList();
      if (reports.length != decoded.length) {
        await saveReports(reports);
      }
      return reports..sort((a, b) => b.reportDate.compareTo(a.reportDate));
    } on FormatException {
      await preferences.remove(_storageKey);
      return [];
    }
  }

  @override
  Future<void> saveReports(List<MedicalReport> reports) async {
    final preferences = await _preferences();
    await preferences.setString(
      _storageKey,
      jsonEncode(reports.map((report) => report.toJson()).toList()),
    );
  }

  @override
  Future<String> storeDocument({
    required String sourcePath,
    required String originalFileName,
  }) async {
    final stored = await _fileService.copyIntoVault(
      sourcePath: sourcePath,
      originalFileName: originalFileName,
    );
    return stored.path;
  }

  @override
  Future<void> deleteDocument(MedicalReport report) =>
      _fileService.deleteFromVault(report.pdfAssetPath);
}
