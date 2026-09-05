import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';


class RecoveryCareScreen extends ConsumerStatefulWidget {
  const RecoveryCareScreen({super.key});

  @override
  ConsumerState<RecoveryCareScreen> createState() => _RecoveryCareScreenState();
}

class _RecoveryCareScreenState extends ConsumerState<RecoveryCareScreen> {
  String _selectedSurgery = 'Knee Replacement';

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
              'Surgery Care',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Guidance. Recovery. Better outcomes.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Procedures Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  hintText: 'Search procedures (e.g. Knee Replacement)...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 2. Select Your Surgery Header
            const Text(
              'Select Your Surgery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // 4 Surgery Category Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSurgeryTypeCard(
                    title: 'Knee\nReplacement',
                    icon: Icons.accessibility_new_rounded,
                    iconColor: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFF0FDFA),
                    borderColor: const Color(0xFF99F6E4),
                  ),
                  const SizedBox(width: 10),
                  _buildSurgeryTypeCard(
                    title: 'Heart\nSurgery',
                    icon: Icons.favorite_outline_rounded,
                    iconColor: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                    borderColor: const Color(0xFFFECACA),
                  ),
                  const SizedBox(width: 10),
                  _buildSurgeryTypeCard(
                    title: 'Gallbladder\nSurgery',
                    icon: Icons.healing_rounded,
                    iconColor: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                  ),
                  const SizedBox(width: 10),
                  _buildSurgeryTypeCard(
                    title: 'Appendix\nSurgery',
                    icon: Icons.medical_information_outlined,
                    iconColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFBFDBFE),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Your Recovery Plan Stepper
            const Text(
              'Your Recovery Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Stepper Items matching Screen 8
            _buildRecoveryStep(
              stepNumber: '1',
              title: 'Pre-Surgery',
              subtitle: 'What to prepare, tests, and tips',
              isCurrent: false,
            ),
            _buildRecoveryStep(
              stepNumber: '2',
              title: 'Hospital Stay',
              subtitle: 'What to expect',
              isCurrent: false,
            ),
            _buildRecoveryStep(
              stepNumber: '3',
              title: 'Post-Surgery Care',
              subtitle: 'Recovery timeline and precautions',
              isCurrent: true,
            ),
            _buildRecoveryStep(
              stepNumber: '4',
              title: 'Follow-up Reminders',
              subtitle: 'Keep track of your recovery',
              isCurrent: false,
              isLast: true,
            ),
            const SizedBox(height: 18),

            // 4. Bottom Support Card matching Screen 8
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "You're not alone.\nWe're with you at every step.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0369A1),
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
                      Icons.medication_liquid_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
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

  Widget _buildSurgeryTypeCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    final isSelected = _selectedSurgery == title.replaceAll('\n', ' ');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSurgery = title.replaceAll('\n', ' ');
        });
      },
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: isCurrent ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Active',
                style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
