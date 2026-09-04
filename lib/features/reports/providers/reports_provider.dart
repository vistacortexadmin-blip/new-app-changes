import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../../../core/storage/seed_data.dart';

class ReportsState {
  final List<MedicalReport> reports;
  final ReportCategory? selectedCategory;
  final String searchQuery;
  final bool isLoading;

  ReportsState({
    required this.reports,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<MedicalReport> get filteredReports {
    return reports.where((r) {
      final matchesCategory =
          selectedCategory == null || r.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.labProvider.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.doctorName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.parameters.any((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  ReportsState copyWith({
    List<MedicalReport>? reports,
    ReportCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier()
      : super(ReportsState(reports: SeedData.initialReports));

  void setCategoryFilter(ReportCategory? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addReport(MedicalReport report) {
    state = state.copyWith(reports: [report, ...state.reports]);
  }

  void deleteReport(String id) {
    state = state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
    );
  }

  // Parameter historical values across all reports
  List<Map<String, dynamic>> getHistoricalParameterTrends(String parameterName) {
    final List<Map<String, dynamic>> trendPoints = [];
    
    // Sort reports chronologically ascending
    final sortedReports = [...state.reports]
      ..sort((a, b) => a.reportDate.compareTo(b.reportDate));

    for (final report in sortedReports) {
      final matchingParam = report.parameters.firstWhere(
        (p) => p.name.toLowerCase() == parameterName.toLowerCase(),
        orElse: () => TestParameter(
          id: '',
          name: '',
          value: -1,
          unit: '',
          minNormal: 0,
          maxNormal: 0,
        ),
      );

      if (matchingParam.value >= 0) {
        trendPoints.add({
          'date': report.reportDate,
          'value': matchingParam.value,
          'unit': matchingParam.unit,
          'reportTitle': report.title,
          'status': matchingParam.status,
        });
      }
    }

    return trendPoints;
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier();
});
