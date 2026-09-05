import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';


class FamilyConnectScreen extends ConsumerStatefulWidget {
  const FamilyConnectScreen({super.key});

  @override
  ConsumerState<FamilyConnectScreen> createState() => _FamilyConnectScreenState();
}

class _FamilyConnectScreenState extends ConsumerState<FamilyConnectScreen> {
  String _selectedTab = 'Shared Reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Connect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Health is stronger together.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: () => _showAddMemberModal(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Family Members Avatars Row matching Screen 9
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Dotted Add Member Button
                  GestureDetector(
                    onTap: () => _showAddMemberModal(context),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
                            color: const Color(0xFFEFF6FF),
                          ),
                          child: const Icon(Icons.add, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add Member',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const Text(' ', style: TextStyle(fontSize: 9)), // Spacer
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Member 1: Mom (Primary Care)
                  _buildMemberAvatar(
                    name: 'Mom',
                    role: 'Primary Care',
                    avatarText: 'M',
                    avatarBg: const Color(0xFFFDE68A),
                    avatarColor: const Color(0xFF92400E),
                  ),
                  const SizedBox(width: 14),

                  // Member 2: Dad
                  _buildMemberAvatar(
                    name: 'Dad',
                    avatarText: 'D',
                    avatarBg: const Color(0xFFBFDBFE),
                    avatarColor: const Color(0xFF1E40AF),
                  ),
                  const SizedBox(width: 14),

                  // Member 3: Sister
                  _buildMemberAvatar(
                    name: 'Sister',
                    avatarText: 'S',
                    avatarBg: const Color(0xFFFBCFE8),
                    avatarColor: const Color(0xFF9D174D),
                  ),
                  const SizedBox(width: 14),

                  // Member 4: Brother
                  _buildMemberAvatar(
                    name: 'Brother',
                    avatarText: 'B',
                    avatarBg: const Color(0xFFA7F3D0),
                    avatarColor: const Color(0xFF065F46),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Segmented Pill Tabs matching Screen 9
            Row(
              children: [
                _buildSegmentPill('Shared Reports'),
                const SizedBox(width: 8),
                _buildSegmentPill('Reminders'),
                const SizedBox(width: 8),
                _buildSegmentPill('Access'),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Shared Reports List matching Screen 9
            _buildSharedReportItem(
              title: "Mom's Blood Test",
              date: '12 Aug 2025',
              badgeText: 'Normal',
              isSuccess: true,
              iconColor: const Color(0xFFEF4444),
              iconBgColor: const Color(0xFFFEE2E2),
            ),
            _buildSharedReportItem(
              title: "Dad's ECG",
              date: '05 Jul 2025',
              badgeText: 'View',
              isSuccess: false,
              iconColor: const Color(0xFFF97316),
              iconBgColor: const Color(0xFFFFF7ED),
            ),
            _buildSharedReportItem(
              title: "Sister's Thyroid Test",
              date: '20 Jun 2025',
              badgeText: 'Normal',
              isSuccess: true,
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFECFDF5),
            ),
            _buildSharedReportItem(
              title: "Brother's Vitamin D",
              date: '10 May 2025',
              badgeText: 'View',
              isSuccess: false,
              iconColor: const Color(0xFF2563EB),
              iconBgColor: const Color(0xFFEFF6FF),
            ),
            const SizedBox(height: 16),

            // 4. Bottom Support Card matching Screen 9
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Care for your loved ones,\nall in one place.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5B21B6),
                      height: 1.3,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diversity_1_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar({
    required String name,
    String? role,
    required String avatarText,
    required Color avatarBg,
    required Color avatarColor,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              avatarText,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        if (role != null)
          Text(
            role,
            style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
          )
        else
          const Text(' ', style: TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _buildSegmentPill(String label) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSharedReportItem({
    required String title,
    required String date,
    required String badgeText,
    required bool isSuccess,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSuccess ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
              ),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSuccess ? const Color(0xFF10B981) : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  void _showAddMemberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Family Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Connect a family caregiver for shared notifications.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Name (e.g. Ramesh Sharma)')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Relationship (e.g. Father, Mother)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Caregiver invite link generated!')),
                    );
                  },
                  child: const Text('Send Invitation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
