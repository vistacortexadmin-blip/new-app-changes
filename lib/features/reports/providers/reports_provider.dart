import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/trend_calculator.dart';
import '../data/local_reports_repository.dart';
import '../data/reports_repository.dart';
import '../models/report_model.dart';
import '../models/report_upload_policy.dart';
import '../services/backend_report_analysis_service.dart';
import '../services/report_analysis_service.dart';

class ReportImportDraft {
  final String sourcePath;
  final String originalFileName;
  final ReportDocumentType documentType;
  final String title;
  final ReportCategory category;
  final String labProvider;
  final String doctorName;
  final DateTime reportDate;

  const ReportImportDraft({
    required this.sourcePath,
    required this.originalFileName,
    required this.documentType,
    required this.title,
    required this.category,
    required this.labProvider,
    required this.doctorName,
    required this.reportDate,
  });
}

class ReportsState {
  final List<MedicalReport> reports;
  final ReportCategory? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isUploading;
  final Set<String> analyzingReportIds;
  final String? errorMessage;

  const ReportsState({
    this.reports = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = true,
    this.isUploading = false,
    this.analyzingReportIds = const {},
    this.errorMessage,
  });

  List<MedicalReport> get filteredReports {
    final query = searchQuery.trim().toLowerCase();
    return reports.where((report) {
      final matchesCategory =
          selectedCategory == null || report.category == selectedCategory;
      final matchesSearch = query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.labProvider.toLowerCase().contains(query) ||
          report.doctorName.toLowerCase().contains(query) ||
          report.parameters
              .any((parameter) => parameter.name.toLowerCase().contains(query));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  ReportsState copyWith({
    List<MedicalReport>? reports,
    ReportCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
    bool? isUploading,
    Set<String>? analyzingReportIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      analyzingReportIds: analyzingReportIds ?? this.analyzingReportIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;
  final ReportAnalysisService _analysisService;
  final Uuid _uuid;

  ReportsNotifier(
    this._repository, {
    ReportAnalysisService? analysisService,
    Uuid? uuid,
    bool autoLoad = true,
  })  : _analysisService = analysisService ?? LocalReportAnalysisService(),
        _uuid = uuid ?? const Uuid(),
        super(const ReportsState()) {
    if (autoLoad) initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final reports = await _repository.loadReports();
      state = state.copyWith(
        reports: reports,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load your medical reports.',
      );
    }
  }

  void setCategoryFilter(ReportCategory? category) {
    if (category == null || state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
      return;
    }
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<MedicalReport?> importReport(ReportImportDraft draft) async {
    state = state.copyWith(isUploading: true, clearError: true);
    MedicalReport? importedReport;
    try {
      final storedPath = await _repository.storeDocument(
        sourcePath: draft.sourcePath,
        originalFileName: draft.originalFileName,
      );
      ReportAnalysisResult analysis;
      try {
        analysis = await _analysisService.analyzeDocument(
          documentPath: storedPath,
          documentType: draft.documentType,
          category: draft.category,
        );
      } catch (_) {
        analysis = const ReportAnalysisResult(
          parameters: [],
          summary:
              'Automatic analysis could not be completed. The original report is stored and you can retry analysis from the report details screen.',
          questionsForDoctor: [],
          dietRecommendation: null,
          status: ReportAnalysisStatus.failed,
        );
      }
      importedReport = MedicalReport(
        id: 'report_${_uuid.v4()}',
        title: draft.title.trim(),
        category: draft.category,
        labProvider: draft.labProvider.trim(),
        doctorName: draft.doctorName.trim().isEmpty
            ? 'Not specified'
            : draft.doctorName.trim(),
        reportDate: draft.reportDate,
        pdfAssetPath: storedPath,
        documentType: draft.documentType,
        originalFileName: draft.originalFileName,
        summaryPlainLanguage: analysis.summary,
        questionsForDoctor: analysis.questionsForDoctor,
        parameters: analysis.parameters,
        dietRecommendation: analysis.dietRecommendation,
        analysisStatus: analysis.status,
        analyzedAt: DateTime.now(),
        isFlagged: analysis.parameters.any(
          (parameter) => parameter.status != ValueStatus.normal,
        ),
      );

      final reports = [importedReport, ...state.reports];
      await _repository.saveReports(reports);
      state = state.copyWith(
        reports: reports,
        isUploading: false,
        clearError: true,
      );
      return importedReport;
    } on EmptyReportFileException {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'The selected file is empty.',
      );
      return null;
    } on ReportFileTooLargeException {
      state = state.copyWith(
        isUploading: false,
        errorMessage:
            'Choose a file smaller than ${ReportUploadPolicy.maxFileSizeLabel}.',
      );
      return null;
    } on ReportVaultFullException {
      state = state.copyWith(
        isUploading: false,
        errorMessage:
            'Report storage is full. Delete an older report before adding another.',
      );
      return null;
    } catch (_) {
      if (importedReport != null) {
        await _repository.deleteDocument(importedReport);
      }
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'The report could not be imported. Please try again.',
      );
      return null;
    }
  }

  Future<bool> analyzeReport(String id) async {
    final report = state.reports.where((item) => item.id == id).firstOrNull;
    if (report == null || !report.hasDocument) return false;

    state = state.copyWith(
      analyzingReportIds: {...state.analyzingReportIds, id},
      clearError: true,
    );
    try {
      final analysis = await _analysisService.analyzeDocument(
        documentPath: report.pdfAssetPath,
        documentType: report.documentType,
        category: report.category,
      );
      final updatedReport = report.copyWith(
        summaryPlainLanguage: analysis.summary,
        questionsForDoctor: analysis.questionsForDoctor,
        parameters: analysis.parameters,
        dietRecommendation: analysis.dietRecommendation,
        clearDietRecommendation: analysis.dietRecommendation == null,
        analysisStatus: analysis.status,
        analyzedAt: DateTime.now(),
        isFlagged: analysis.parameters.any(
          (parameter) => parameter.status != ValueStatus.normal,
        ),
      );
      final reports = state.reports
          .map((item) => item.id == id ? updatedReport : item)
          .toList();
      await _repository.saveReports(reports);
      state = state.copyWith(
        reports: reports,
        analyzingReportIds: {...state.analyzingReportIds}..remove(id),
        clearError: true,
      );
      return true;
    } catch (_) {
      final reports = state.reports.map((item) {
        if (item.id != id || item.hasAnalysis) return item;
        return item.copyWith(
          summaryPlainLanguage:
              'Automatic analysis could not be completed. Verify the original report and try again.',
          analysisStatus: ReportAnalysisStatus.failed,
          analyzedAt: DateTime.now(),
        );
      }).toList();
      await _repository.saveReports(reports);
      state = state.copyWith(
        reports: reports,
        analyzingReportIds: {...state.analyzingReportIds}..remove(id),
        errorMessage: 'Report analysis failed. Check the file and try again.',
      );
      return false;
    }
  }

  Future<bool> deleteReport(String id) async {
    final report = state.reports.where((item) => item.id == id).firstOrNull;
    if (report == null) return false;

    final updated = state.reports.where((item) => item.id != id).toList();
    try {
      await _repository.saveReports(updated);
      await _repository.deleteDocument(report);
      state = state.copyWith(reports: updated, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'The report could not be deleted.',
      );
      return false;
    }
  }

  List<Map<String, dynamic>> getHistoricalParameterTrends(
    String parameterName,
  ) {
    final trendPoints = <Map<String, dynamic>>[];
    final sortedReports = [...state.reports]
      ..sort((a, b) => a.reportDate.compareTo(b.reportDate));

    for (final report in sortedReports) {
      for (final parameter in report.parameters) {
        if (parameter.name.toLowerCase() == parameterName.toLowerCase()) {
          trendPoints.add({
            'date': report.reportDate,
            'value': parameter.value,
            'unit': parameter.unit,
            'reportTitle': report.title,
            'status': parameter.status,
          });
          break;
        }
      }
    }
    return trendPoints;
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return LocalReportsRepository();
});

final reportAnalysisServiceProvider = Provider<ReportAnalysisService>((ref) {
  final localAnalysis = LocalReportAnalysisService();
  const configuredEndpoint = String.fromEnvironment(
    'VISTACORTEX_ANALYSIS_API_URL',
  );
  final endpoint = Uri.tryParse(configuredEndpoint.trim());
  if (endpoint == null ||
      !(endpoint.isScheme('https') ||
          (endpoint.isScheme('http') && endpoint.host == '10.0.2.2'))) {
    return localAnalysis;
  }

  return FallbackReportAnalysisService(
    primary: BackendReportAnalysisService(
      endpoint: endpoint,
      authTokenProvider: () async {
        try {
          return await FirebaseAuth.instance.currentUser?.getIdToken();
        } catch (_) {
          return null;
        }
      },
    ),
    fallback: localAnalysis,
  );
});

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(
    ref.watch(reportsRepositoryProvider),
    analysisService: ref.watch(reportAnalysisServiceProvider),
  );
});
