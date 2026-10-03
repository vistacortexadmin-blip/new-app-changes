import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/security/security_audit_model.dart';
import '../../../core/security/security_audit_service.dart';
import '../../../core/utils/safety_disclaimer.dart';
import '../../../core/utils/trend_calculator.dart';
import '../models/report_model.dart';
import '../providers/reports_provider.dart';
import 'parameter_trend_screen.dart';
import 'pdf_view_modal.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  final MedicalReport report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  ConsumerState<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedDietFilter = 'Daily Plan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SecurityAuditService().record(
      actionType: AuditActionType.phiReportViewed,
      resourceType: AuditResourceType.phiMedicalReport,
      resourceId: widget.report.id,
      dataClassification: DataClassification.phi,
      metadata: {
        'reportTitle': widget.report.title,
        'labName': widget.report.labProvider,
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportsProvider);
    final report = reportState.reports
            .where((item) => item.id == widget.report.id)
            .firstOrNull ??
        widget.report;
    final isAnalyzing = reportState.analyzingReportIds.contains(report.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${DateFormat('dd MMM yyyy').format(report.reportDate)} • ${report.labProvider}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Report'),
                Tab(text: 'Analysis'),
                Tab(text: 'Diet Plan'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportTab(report, isAnalyzing),
          _buildAnalysisTab(report, isAnalyzing),
          _buildDietPlanTab(report, isAnalyzing),
        ],
      ),
    );
  }

  Widget _buildReportTab(MedicalReport report, bool isAnalyzing) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _pill(
                    report.categoryDisplayName,
                    AppColors.primary,
                    AppColors.primarySurface,
                  ),
                  const Spacer(),
                  Icon(
                    report.hasDocument
                        ? Icons.lock_rounded
                        : Icons.info_outline_rounded,
                    size: 15,
                    color: report.hasDocument
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    report.hasDocument
                        ? 'Stored on device'
                        : 'No document attached',
                    style: TextStyle(
                      color: report.hasDocument
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _metadataRow(Icons.local_hospital_outlined, report.labProvider),
              const SizedBox(height: 6),
              _metadataRow(Icons.person_outline_rounded, report.doctorName),
              if (report.originalFileName != null) ...[
                const SizedBox(height: 6),
                _metadataRow(
                  Icons.attach_file_rounded,
                  report.originalFileName!,
                ),
              ],
              const Divider(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('view-original-document'),
                  onPressed: report.hasDocument
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerModal(
                                title: report.title,
                                assetPath: report.pdfAssetPath,
                                documentType: report.documentType,
                                originalFileName: report.originalFileName,
                              ),
                            ),
                          )
                      : null,
                  icon: Icon(
                    report.documentType == ReportDocumentType.image
                        ? Icons.image_outlined
                        : Icons.picture_as_pdf_rounded,
                    size: 19,
                  ),
                  label: Text(
                    report.hasDocument
                        ? 'View Original Document'
                        : 'No Original Document Attached',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Extracted Parameters',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (report.parameters.isEmpty)
          _analysisEmptyState(report, isAnalyzing)
        else
          ...report.parameters.map(_parameterRow),
      ],
    );
  }

  Widget _buildAnalysisTab(MedicalReport report, bool isAnalyzing) {
    final abnormal = report.parameters
        .where((item) => item.status != ValueStatus.normal)
        .length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (isAnalyzing)
          _card(
            child: const Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Extracting and analyzing this report…')),
              ],
            ),
          )
        else if (report.parameters.isEmpty)
          _analysisEmptyState(report, isAnalyzing)
        else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: abnormal == 0
                  ? AppColors.successSurface
                  : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: abnormal == 0
                    ? AppColors.success.withValues(alpha: 0.35)
                    : AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  abnormal == 0
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: abnormal == 0 ? AppColors.success : AppColors.warning,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        abnormal == 0
                            ? 'All extracted values are in range'
                            : '$abnormal value${abnormal == 1 ? '' : 's'} need review',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        report.summaryPlainLanguage,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (report.parameters.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'Report Parameters',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...report.parameters.map(_analysisParameterCard),
        ],
        if (report.questionsForDoctor.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'Questions for your doctor',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              children: report.questionsForDoctor
                  .map(
                    (question) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              question,
                              style: const TextStyle(height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 18),
        const SafetyDisclaimerBanner(compact: true),
      ],
    );
  }

  Widget _buildDietPlanTab(MedicalReport report, bool isAnalyzing) {
    final plan = report.effectiveDietPlan;
    if (plan == null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _analysisEmptyState(
            report,
            isAnalyzing,
            message:
                'A diet plan is created only after biomarkers are extracted from this report. It will be linked to the actual findings, not a preset category plan.',
          ),
          const SizedBox(height: 18),
          const SafetyDisclaimerBanner(compact: true),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          plan.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          plan.rationale,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _dietFilter('Daily Plan'),
            const SizedBox(width: 7),
            _dietFilter('Foods to Include'),
            const SizedBox(width: 7),
            _dietFilter('Foods to Avoid'),
          ],
        ),
        const SizedBox(height: 18),
        if (_selectedDietFilter == 'Daily Plan')
          ...plan.dailyMeals.asMap().entries.map(
                (entry) => _mealCard(entry.value, entry.key),
              )
        else if (_selectedDietFilter == 'Foods to Include')
          _foodList(
            plan.foodsToEat,
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          )
        else
          _foodList(
            plan.foodsToAvoid,
            icon: Icons.do_not_disturb_alt_rounded,
            color: AppColors.error,
          ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nutrition tip',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.nutritionTip,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SafetyDisclaimerBanner(compact: true),
      ],
    );
  }

  Widget _analysisEmptyState(
    MedicalReport report,
    bool isAnalyzing, {
    String? message,
  }) {
    final statusMessage = switch (report.analysisStatus) {
      ReportAnalysisStatus.failed =>
        'Analysis could not be completed. The original document is still stored safely.',
      ReportAnalysisStatus.noValuesFound =>
        'No supported biomarkers were detected. Use a clear, upright lab report and verify that values and reference ranges are visible.',
      _ =>
        'No structured biomarkers are available yet. Analyze the original document to extract supported lab values.',
    };
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message ?? statusMessage,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (report.hasDocument) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: Key('analyze-report-${report.id}'),
                onPressed: isAnalyzing ? null : () => _analyzeReport(report),
                icon: isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(isAnalyzing ? 'Analyzing…' : 'Analyze Report'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _analyzeReport(MedicalReport report) async {
    final success =
        await ref.read(reportsProvider.notifier).analyzeReport(report.id);
    if (!mounted) return;
    final refreshed = ref
        .read(reportsProvider)
        .reports
        .where((item) => item.id == report.id)
        .firstOrNull;
    final foundValues = refreshed?.parameters.isNotEmpty ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? foundValues
                  ? 'Report analyzed and saved.'
                  : 'Analysis finished, but no supported biomarkers were found.'
              : 'Analysis failed. Check the document and try again.',
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );

  Widget _metadataRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );

  Widget _pill(String text, Color color, Color background) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _parameterRow(TestParameter parameter) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parameter.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Reference: ${parameter.minNormal}–${parameter.maxNormal} ${parameter.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${parameter.value} ${parameter.unit}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: TrendCalculator.getStatusColor(parameter.status),
              ),
            ),
          ],
        ),
      );

  Widget _analysisParameterCard(TestParameter parameter) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParameterTrendScreen(
                parameterName: parameter.name,
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: TrendCalculator.getStatusColor(parameter.status)
                .withValues(alpha: 0.12),
            child: Icon(
              Icons.monitor_heart_outlined,
              color: TrendCalculator.getStatusColor(parameter.status),
            ),
          ),
          title: Text(
            parameter.name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${parameter.value} ${parameter.unit} • ${TrendCalculator.getStatusLabel(parameter.status)}',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );

  Widget _dietFilter(String label) {
    final selected = _selectedDietFilter == label;
    return Expanded(
      child: InkWell(
        key: Key('diet-filter-$label'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedDietFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mealCard(DietMeal meal, int index) {
    const colors = [
      AppColors.accentAmber,
      AppColors.success,
      AppColors.accentRose,
      AppColors.accentBlue,
    ];
    const icons = [
      Icons.breakfast_dining_rounded,
      Icons.lunch_dining_rounded,
      Icons.bakery_dining_rounded,
      Icons.dinner_dining_rounded,
    ];
    final color = colors[index % colors.length];
    return Container(
      key: Key('diet-meal-${meal.mealType}'),
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  meal.recommendedFood,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal.nutrition,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 27,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icons[index % icons.length], color: color),
          ),
        ],
      ),
    );
  }

  Widget _foodList(
    List<String> foods, {
    required IconData icon,
    required Color color,
  }) =>
      _card(
        child: Column(
          children: foods
              .map(
                (food) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 21),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          food,
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
}
