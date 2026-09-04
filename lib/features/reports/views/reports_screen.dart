import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../providers/reports_provider.dart';
import '../models/report_model.dart';
import 'report_details_screen.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final reports = state.filteredReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Medical Test Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
            tooltip: 'Upload Lab Report',
            onPressed: () => _showUploadDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(reportsProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search test name, lab, or doctor...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          // 2. Category Filter Chips
          Container(
            color: AppColors.background,
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _buildCategoryChip(
                  context,
                  ref,
                  label: 'All Reports',
                  isSelected: state.selectedCategory == null,
                  onSelected: () =>
                      ref.read(reportsProvider.notifier).setCategoryFilter(null),
                ),
                ...ReportCategory.values.map((cat) {
                  return _buildCategoryChip(
                    context,
                    ref,
                    label: _categoryName(cat),
                    isSelected: state.selectedCategory == cat,
                    onSelected: () =>
                        ref.read(reportsProvider.notifier).setCategoryFilter(cat),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 3. Reports List
          Expanded(
            child: reports.isEmpty
                ? const Center(
                    child: Text(
                      'No reports matching your filter.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportItemCard(context, report);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
        label: const Text('Upload Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showUploadDialog(context, ref),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primarySurface,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildReportItemCard(BuildContext context, MedicalReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailsScreen(report: report),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.categoryDisplayName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(report.reportDate),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.labProvider} · ${report.doctorName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Divider(height: 20, color: AppColors.divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${report.parameters.length} Parameters Extracted',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Medical Test Report',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload PDF or capture physical lab sheets for automated AI transcription and storage.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                ),
                title: const Text('Choose PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Files from device storage or SD card', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateNewUpload(context, ref, 'Thyroid Profile Free T3/T4', ReportCategory.diabeticPanel);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Snap a clear photo of your paper test sheet', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateNewUpload(context, ref, 'Renal Kidney Function Panel', ReportCategory.generalCheckup);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateNewUpload(
      BuildContext context, WidgetRef ref, String title, ReportCategory cat) {
    final newReport = MedicalReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: cat,
      labProvider: 'Central Pathology Laboratory',
      doctorName: 'Dr. Vivek Mehra, MD',
      reportDate: DateTime.now(),
      pdfAssetPath: 'assets/documents/sample_report.pdf',
      summaryPlainLanguage:
          'Newly transcribed report parameters are in stable physiological boundaries. Verified with OCR analysis.',
      questionsForDoctor: [
        'Do I need to maintain current diet restrictions?',
      ],
      parameters: [
        TestParameter(
          id: 'p_new1',
          name: 'Serum Creatinine',
          value: 0.95,
          unit: 'mg/dL',
          minNormal: 0.7,
          maxNormal: 1.3,
          interpretation: 'Healthy renal clearance.',
        ),
        TestParameter(
          id: 'p_new2',
          name: 'Blood Urea Nitrogen (BUN)',
          value: 16.0,
          unit: 'mg/dL',
          minNormal: 7.0,
          maxNormal: 20.0,
          interpretation: 'Normal nitrogen balance.',
        ),
      ],
    );

    ref.read(reportsProvider.notifier).addReport(newReport);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('Successfully transcribed and added "$title"!'),
      ),
    );
  }

  String _categoryName(ReportCategory cat) {
    switch (cat) {
      case ReportCategory.bloodTest:
        return 'Blood Count';
      case ReportCategory.lipidProfile:
        return 'Lipid & Heart';
      case ReportCategory.diabeticPanel:
        return 'Diabetes / Glucose';
      case ReportCategory.cardiology:
        return 'Cardiology';
      case ReportCategory.radiology:
        return 'Radiology';
      case ReportCategory.urineAnalysis:
        return 'Urinalysis';
      case ReportCategory.generalCheckup:
        return 'General';
    }
  }
}
