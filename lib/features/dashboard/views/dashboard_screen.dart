import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../reminders/models/reminder_model.dart';
import '../../family_connect/views/family_connect_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(remindersProvider);
    final lowSupplyCount = remindersState.lowSupplyMedicines.length;
    final upcomingTests = remindersState.upcomingTests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.health_and_safety_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'VISTACORTEX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: 0.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Patient Greeting
            _buildPatientGreeting(),
            const SizedBox(height: 20),

            // 2. Alert Strips (only if needed)
            if (lowSupplyCount > 0)
              _buildAlertStrip(
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
                bgColor: AppColors.warningSurface,
                text: '$lowSupplyCount medicine${lowSupplyCount > 1 ? 's' : ''} running low',
                actionLabel: 'Refill',
                onAction: () => onNavigateTab(1),
              ),
            if (lowSupplyCount > 0) const SizedBox(height: 8),
            if (upcomingTests.isNotEmpty)
              _buildAlertStrip(
                icon: Icons.event_note_rounded,
                color: AppColors.info,
                bgColor: AppColors.infoSurface,
                text: '${upcomingTests.first.testName} in ${upcomingTests.first.daysUntilTest} days',
                actionLabel: 'View',
                onAction: () => onNavigateTab(1),
              ),
            if (lowSupplyCount > 0 || upcomingTests.isNotEmpty)
              const SizedBox(height: 24),

            // 3. Feature Modules Grid
            const Text(
              'Your Health Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildModulesGrid(context),
            const SizedBox(height: 28),

            // 4. Today's Medications (compact)
            _buildTodayMedsSection(context, ref, remindersState),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── 1. Patient Greeting ───
  Widget _buildPatientGreeting() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good day, Vijay 👋',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Post-Op Recovery · Day 8 of 28',
            style: TextStyle(
              color: Color(0xFFD6EADF),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Alert Strip ───
  Widget _buildAlertStrip({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String text,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Modules Grid ───
  Widget _buildModulesGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildModuleCard(
              icon: Icons.description_rounded,
              label: 'Reports',
              color: AppColors.primary,
              onTap: () => onNavigateTab(0),
            ),
            const SizedBox(width: 12),
            _buildModuleCard(
              icon: Icons.medication_rounded,
              label: 'Medicines',
              color: AppColors.accentBlue,
              onTap: () => onNavigateTab(1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModuleCard(
              icon: Icons.healing_rounded,
              label: 'Care & Diet',
              color: AppColors.accentAmber,
              onTap: () => onNavigateTab(3),
            ),
            const SizedBox(width: 12),
            _buildModuleCard(
              icon: Icons.family_restroom_rounded,
              label: 'Family',
              color: AppColors.accentPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyConnectScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModuleCard(
              icon: Icons.calendar_month_rounded,
              label: 'Book Tests',
              color: AppColors.accentTeal,
              onTap: () => onNavigateTab(4),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox(height: 90)),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 4. Today's Meds (Compact) ───
  Widget _buildTodayMedsSection(
      BuildContext context, WidgetRef ref, RemindersState remindersState) {
    final allDoses = remindersState.medicines.expand((med) {
      return med.dailySchedules.map((schedule) => MapEntry(med, schedule));
    }).take(3).toList();

    if (allDoses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Meds",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => onNavigateTab(1),
              child: const Text(
                'See all →',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...allDoses.map((entry) =>
            _buildDoseTile(context, ref, entry.key, entry.value)),
      ],
    );
  }

  Widget _buildDoseTile(BuildContext context, WidgetRef ref,
      MedicineReminder med, DoseSchedule schedule) {
    final isTaken = schedule.status == AdherenceStatus.taken;
    final isSkipped = schedule.status == AdherenceStatus.skipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTaken
              ? AppColors.success.withOpacity(0.3)
              : (isSkipped ? AppColors.error.withOpacity(0.3) : AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Medicine icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTaken
                  ? AppColors.successSurface
                  : (isSkipped ? AppColors.errorSurface : AppColors.primarySurface),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.medication_rounded,
              size: 20,
              color: isTaken
                  ? AppColors.success
                  : (isSkipped ? AppColors.error : AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          // Name + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.medicineName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.timeString} · ${med.dosage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Action
          if (isTaken || isSkipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isTaken ? AppColors.successSurface : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isTaken ? '✓ Taken' : 'Skipped',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isTaken ? AppColors.success : AppColors.error,
                ),
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.read(remindersProvider.notifier).markDoseTaken(
                      medicineId: med.id,
                      timeOfDay: schedule.timeOfDay,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${med.medicineName} marked as taken')),
                );
              },
              child: const Text(
                'Take',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
