import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../providers/reports_provider.dart';
import 'report_details_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final reports = state.reports;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header Row with Title, Subtitle, and circular '+' button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          'Store, organize and access all your\nmedical reports in one place.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Circular blue '+' button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 24),
                      onPressed: () => _showUploadDialog(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Blood Test', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Imaging', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Others', isDark, cardBg, borderColor, textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Reports List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                children: [
                  _buildReportTile(
                    title: 'Blood Test - CBC',
                    hospital: 'Apollo Hospitals',
                    date: '12 Aug 2025',
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: isDark ? const Color(0xFF4C1D1D) : const Color(0xFFFEE2E2),
                    badgeText: 'Normal',
                    isSuccessBadge: true,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () {
                      if (reports.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailsScreen(report: reports.first),
                          ),
                        );
                      }
                    },
                  ),
                  _buildReportTile(
                    title: 'MRI - Brain',
                    hospital: 'Yashoda Hospitals',
                    date: '05 Jul 2025',
                    icon: Icons.personal_injury_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                    badgeText: 'View',
                    isSuccessBadge: false,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () {
                      if (reports.length > 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailsScreen(report: reports[1]),
                          ),
                        );
                      }
                    },
                  ),
                  _buildReportTile(
                    title: 'Lipid Profile',
                    hospital: 'AIG Hospitals',
                    date: '20 May 2025',
                    icon: Icons.biotech_rounded,
                    iconColor: const Color(0xFF0D9488),
                    iconBgColor: isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1),
                    badgeText: 'Normal',
                    isSuccessBadge: true,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () {
                      if (reports.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailsScreen(report: reports.first),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textSecondary,
  ) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReportTile({
    required String title,
    required String hospital,
    required String date,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required bool isSuccessBadge,
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Title and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$hospital · $date',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSuccessBadge
                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                      : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSuccessBadge
                        ? (isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
                        : (isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE)),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSuccessBadge ? const Color(0xFF10B981) : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Three dots menu
              Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
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
              Text(
                'Upload Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a PDF or take a photo of your paper test report.',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A5F) : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                ),
                title: Text('Choose PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                subtitle: Text('From your device storage', style: TextStyle(fontSize: 12, color: textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report uploaded and transcribed successfully!')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A5F) : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                subtitle: Text('Take a photo of physical report sheet', style: TextStyle(fontSize: 12, color: textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report scanned and processed!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
