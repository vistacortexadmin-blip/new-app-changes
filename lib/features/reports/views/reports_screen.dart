import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/utils/trend_calculator.dart';
import '../models/report_model.dart';
import '../models/report_upload_policy.dart';
import '../providers/reports_provider.dart';
import 'report_details_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _searchController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final reports = state.filteredReports;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final secondaryColor =
        isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Store, organize and access your medical reports.',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: FilledButton(
                      key: const Key('add-report-button'),
                      onPressed: state.isUploading
                          ? null
                          : () => _showUploadOptions(context),
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primary,
                      ),
                      child: state.isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_rounded, size: 26),
                    ),
                  ),
                ],
              ),
            ),
            if (state.isUploading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                key: const Key('report-search-field'),
                controller: _searchController,
                onChanged: ref.read(reportsProvider.notifier).setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search reports, labs or parameters',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: state.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(reportsProvider.notifier)
                                .setSearchQuery('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _categoryOptions.map((option) {
                  final selected = state.selectedCategory == option.category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('filter-${option.label}'),
                      label: Text(option.label),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => ref
                          .read(reportsProvider.notifier)
                          .setCategoryFilter(option.category),
                      selectedColor: AppColors.primary,
                      backgroundColor: cardColor,
                      side: BorderSide(
                        color: selected ? AppColors.primary : borderColor,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : secondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorMessage != null && state.reports.isEmpty
                      ? _ErrorState(
                          message: state.errorMessage!,
                          onRetry:
                              ref.read(reportsProvider.notifier).initialize,
                        )
                      : reports.isEmpty
                          ? _EmptyReportsState(
                              hasFilter: state.searchQuery.isNotEmpty ||
                                  state.selectedCategory != null,
                              onAdd: () => _showUploadOptions(context),
                            )
                          : RefreshIndicator(
                              onRefresh:
                                  ref.read(reportsProvider.notifier).initialize,
                              child: ListView.builder(
                                key: const Key('reports-list'),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 28),
                                itemCount: reports.length,
                                itemBuilder: (context, index) =>
                                    _buildReportTile(
                                  report: reports[index],
                                  cardColor: cardColor,
                                  textColor: textColor,
                                  secondaryColor: secondaryColor,
                                  borderColor: borderColor,
                                  isDark: isDark,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile({
    required MedicalReport report,
    required Color cardColor,
    required Color textColor,
    required Color secondaryColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final needsReview = report.isFlagged ||
        report.parameters.any((item) => item.status != ValueStatus.normal);
    final badgeText = switch (report.analysisStatus) {
      ReportAnalysisStatus.failed => 'Analysis failed',
      ReportAnalysisStatus.noValuesFound => 'No values found',
      ReportAnalysisStatus.notStarted => 'Stored',
      ReportAnalysisStatus.completed => needsReview ? 'Review' : 'Normal',
    };
    final badgeColor = switch (report.analysisStatus) {
      ReportAnalysisStatus.failed => AppColors.error,
      ReportAnalysisStatus.noValuesFound ||
      ReportAnalysisStatus.notStarted =>
        AppColors.textMuted,
      ReportAnalysisStatus.completed =>
        needsReview ? AppColors.warning : AppColors.success,
    };
    final icon = report.documentType == ReportDocumentType.image
        ? Icons.image_rounded
        : _categoryIcon(report.category);

    return Container(
      key: Key('report-${report.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openReport(report),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      _categoryColor(report.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _categoryColor(report.category),
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.labProvider} • ${DateFormat('dd MMM yyyy').format(report.reportDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: secondaryColor),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            report.categoryDisplayName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                key: Key('report-menu-${report.id}'),
                tooltip: 'Report actions',
                icon: Icon(Icons.more_vert_rounded, color: secondaryColor),
                onSelected: (action) {
                  if (action == 'view') _openReport(report);
                  if (action == 'delete') _confirmDelete(report);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.visibility_outlined),
                      title: Text('View report'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      leading:
                          Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text('Delete report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReport(MedicalReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsScreen(report: report),
      ),
    );
  }

  Future<void> _confirmDelete(MedicalReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report?'),
        content: Text(
          '“${report.title}” and its stored document will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deleted =
        await ref.read(reportsProvider.notifier).deleteReport(report.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'Report deleted.' : 'Could not delete report.'),
      ),
    );
  }

  Future<void> _showUploadOptions(BuildContext pageContext) async {
    final isDark = Theme.of(pageContext).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: pageContext,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Medical Report',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'The original file will be copied into the app’s private storage.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Maximum ${ReportUploadPolicy.maxFileSizeLabel} per file and ${ReportUploadPolicy.maxVaultSizeLabel} total.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _UploadOption(
                key: const Key('choose-pdf-option'),
                icon: Icons.picture_as_pdf_rounded,
                title: 'Choose PDF Document',
                subtitle:
                    'Select a PDF up to ${ReportUploadPolicy.maxFileSizeLabel}',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickPdf();
                },
              ),
              const SizedBox(height: 10),
              _UploadOption(
                key: const Key('capture-report-option'),
                icon: Icons.document_scanner_rounded,
                title: 'Capture with Camera',
                subtitle: 'Photograph a physical report page',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _captureReport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file == null) return;
      if (file.path == null) {
        _showMessage('This file is not available offline. Download it first.');
        return;
      }
      if (!await _validateSelectedFile(file.path!)) return;
      await _collectDetailsAndImport(
        sourcePath: file.path!,
        originalFileName: file.name,
        documentType: ReportDocumentType.pdf,
      );
    } catch (_) {
      _showMessage('Could not open the document picker.');
    }
  }

  Future<void> _captureReport() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2200,
        maxHeight: 3200,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image == null) return;
      if (!await _validateSelectedFile(image.path)) return;
      await _collectDetailsAndImport(
        sourcePath: image.path,
        originalFileName: image.name,
        documentType: ReportDocumentType.image,
      );
    } catch (_) {
      _showMessage('Camera access failed. Check the camera permission.');
    }
  }

  Future<void> _collectDetailsAndImport({
    required String sourcePath,
    required String originalFileName,
    required ReportDocumentType documentType,
  }) async {
    if (!mounted) return;
    final initialTitle = _titleFromFileName(originalFileName);
    final draft = await showModalBottomSheet<ReportImportDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ReportDetailsForm(
        sourcePath: sourcePath,
        originalFileName: originalFileName,
        documentType: documentType,
        initialTitle: initialTitle,
      ),
    );
    if (draft == null || !mounted) return;

    final imported =
        await ref.read(reportsProvider.notifier).importReport(draft);
    if (!mounted) return;
    if (imported == null) {
      _showMessage(
        ref.read(reportsProvider).errorMessage ?? 'Import failed.',
      );
      return;
    }
    final importMessage = switch (imported.analysisStatus) {
      ReportAnalysisStatus.completed =>
        '“${imported.title}” was stored and analyzed.',
      ReportAnalysisStatus.noValuesFound =>
        '“${imported.title}” was stored, but no supported values were found.',
      ReportAnalysisStatus.failed =>
        '“${imported.title}” was stored. Analysis can be retried from its details.',
      ReportAnalysisStatus.notStarted =>
        '“${imported.title}” was stored on this device.',
    };
    _showMessage(importMessage);
  }

  Future<bool> _validateSelectedFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      _showMessage('The selected file is no longer available.');
      return false;
    }
    final bytes = await file.length();
    if (bytes <= 0) {
      _showMessage('The selected file is empty.');
      return false;
    }
    if (bytes > ReportUploadPolicy.maxFileSizeBytes) {
      _showMessage(
        'Choose a file smaller than ${ReportUploadPolicy.maxFileSizeLabel}.',
      );
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _titleFromFileName(String name) {
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final words = base
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ');
    if (words.isEmpty || words.first.isEmpty) return 'Medical report';
    return words
        .map((word) =>
            '${word.substring(0, 1).toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  IconData _categoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.radiology:
        return Icons.image_search_rounded;
      case ReportCategory.cardiology:
        return Icons.monitor_heart_rounded;
      case ReportCategory.diabeticPanel:
        return Icons.water_drop_rounded;
      case ReportCategory.urineAnalysis:
        return Icons.science_rounded;
      case ReportCategory.bloodTest:
      case ReportCategory.lipidProfile:
      case ReportCategory.generalCheckup:
        return Icons.description_rounded;
    }
  }

  Color _categoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.radiology:
        return AppColors.accentPurple;
      case ReportCategory.cardiology:
        return AppColors.error;
      case ReportCategory.diabeticPanel:
        return AppColors.accentBlue;
      case ReportCategory.urineAnalysis:
        return AppColors.accentAmber;
      case ReportCategory.bloodTest:
        return AppColors.accentRose;
      case ReportCategory.lipidProfile:
        return AppColors.accentTeal;
      case ReportCategory.generalCheckup:
        return AppColors.primary;
    }
  }
}

class _CategoryOption {
  final String label;
  final ReportCategory? category;

  const _CategoryOption(this.label, this.category);
}

const _categoryOptions = [
  _CategoryOption('All', null),
  _CategoryOption('Blood', ReportCategory.bloodTest),
  _CategoryOption('Lipids', ReportCategory.lipidProfile),
  _CategoryOption('Diabetes', ReportCategory.diabeticPanel),
  _CategoryOption('Cardiology', ReportCategory.cardiology),
  _CategoryOption('Imaging', ReportCategory.radiology),
  _CategoryOption('Urine', ReportCategory.urineAnalysis),
  _CategoryOption('General', ReportCategory.generalCheckup),
];

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _ReportDetailsForm extends StatefulWidget {
  final String sourcePath;
  final String originalFileName;
  final ReportDocumentType documentType;
  final String initialTitle;

  const _ReportDetailsForm({
    required this.sourcePath,
    required this.originalFileName,
    required this.documentType,
    required this.initialTitle,
  });

  @override
  State<_ReportDetailsForm> createState() => _ReportDetailsFormState();
}

class _ReportDetailsFormState extends State<_ReportDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  final _labController = TextEditingController();
  final _doctorController = TextEditingController();
  ReportCategory _category = ReportCategory.generalCheckup;
  DateTime _reportDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _labController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, keyboard + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Report details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                widget.originalFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('report-title-input'),
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'Test / report name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('report-lab-input'),
                controller: _labController,
                decoration: const InputDecoration(labelText: 'Lab or hospital'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor (optional)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReportCategory>(
                key: const Key('report-category-input'),
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Report category'),
                items: ReportCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(_categoryName(category)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Report date'),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_reportDate)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('save-report-button'),
                  onPressed: _submit,
                  icon: const Icon(Icons.lock_rounded),
                  label: const Text('Store Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _reportDate = date);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      ReportImportDraft(
        sourcePath: widget.sourcePath,
        originalFileName: widget.originalFileName,
        documentType: widget.documentType,
        title: _titleController.text,
        category: _category,
        labProvider: _labController.text,
        doctorName: _doctorController.text,
        reportDate: _reportDate,
      ),
    );
  }
}

String _categoryName(ReportCategory category) {
  switch (category) {
    case ReportCategory.bloodTest:
      return 'Blood test / CBC';
    case ReportCategory.lipidProfile:
      return 'Lipid profile';
    case ReportCategory.diabeticPanel:
      return 'Diabetes / HbA1c';
    case ReportCategory.cardiology:
      return 'Cardiology';
    case ReportCategory.radiology:
      return 'MRI / X-Ray / Imaging';
    case ReportCategory.urineAnalysis:
      return 'Urine analysis';
    case ReportCategory.generalCheckup:
      return 'General checkup';
  }
}

class _EmptyReportsState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onAdd;

  const _EmptyReportsState({required this.hasFilter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_copy_outlined,
              size: 58,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              hasFilter ? 'No matching reports' : 'No reports stored yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try another search or category.'
                  : 'Add a PDF or scan a paper report to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (!hasFilter) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add report'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
