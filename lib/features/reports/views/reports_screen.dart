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

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Store, organize and access all your\nmedical reports in one place.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
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

            // 2. Category Filter Chips matching Screen 3
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Blood Test'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Imaging'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Others'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Reports List matching Screen 3
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
                    iconBgColor: const Color(0xFFFEE2E2),
                    badgeText: 'Normal',
                    isSuccessBadge: true,
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
                    iconBgColor: const Color(0xFFEFF6FF),
                    badgeText: 'View',
                    isSuccessBadge: false,
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
                    title: 'X-Ray - Chest',
                    hospital: 'Care Hospitals',
                    date: '20 Jun 2025',
                    icon: Icons.assignment_outlined,
                    iconColor: const Color(0xFFF97316),
                    iconBgColor: const Color(0xFFFFF7ED),
                    badgeText: 'View',
                    isSuccessBadge: false,
                    onTap: () {},
                  ),
                  _buildReportTile(
                    title: 'Lipid Profile',
                    hospital: 'Apollo Hospitals',
                    date: '10 May 2025',
                    icon: Icons.insert_drive_file_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    badgeText: 'Normal',
                    isSuccessBadge: true,
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
                    title: 'Thyroid Test',
                    hospital: 'MedPlus Diagnostics',
                    date: '26 Apr 2025',
                    icon: Icons.science_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    badgeText: 'View',
                    isSuccessBadge: false,
                    onTap: () {},
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

  Widget _buildFilterChip(String label) {
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
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
            color: isSelected ? Colors.white : AppColors.textSecondary,
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title & hospital & date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$hospital • $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSuccessBadge ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSuccessBadge ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
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
              const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                'Upload Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload a PDF or take a photo of your paper test report.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('From your device storage', style: TextStyle(fontSize: 12)),
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
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Take a photo of physical report sheet', style: TextStyle(fontSize: 12)),
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
