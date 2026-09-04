import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/safety_disclaimer.dart';
import '../../reports/providers/reports_provider.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../reminders/models/reminder_model.dart';
import '../../recovery_care/providers/recovery_diet_provider.dart';
import '../../family_connect/providers/family_connect_provider.dart';
import '../../family_connect/views/family_connect_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);
    final remindersState = ref.watch(remindersProvider);
    final recoveryState = ref.watch(recoveryDietProvider);
    final familyState = ref.watch(familyConnectProvider);

    final lowSupplyCount = remindersState.lowSupplyMedicines.length;
    final upcomingTests = remindersState.upcomingTests;
    final plan = recoveryState.recoveryPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.health_and_safety_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISTACORTEX',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Connected Health & Wellness',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
            tooltip: 'Safety & Compliance',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: SafetyDisclaimerBanner(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Patient Greeting Header with Emerald Pattern
            _buildPatientHeader(context),
            const SizedBox(height: 16),

            // 2. Clinical Safety Alert Banner (PRD Requirement)
            const SafetyDisclaimerBanner(compact: true),
            const SizedBox(height: 16),

            // 3. Urgent Alerts (Refills / Upcoming Tests)
            if (lowSupplyCount > 0 || upcomingTests.isNotEmpty)
              _buildUrgentAlertsSection(context, ref, remindersState),

            const SizedBox(height: 16),

            // 4. Quick Actions Hub (PRD 5 Feature Areas)
            _buildQuickModulesGrid(context),
            const SizedBox(height: 20),

            // 5. Today's Medicine Timeline (Interactive Taken/Skipped)
            _buildTodayMedicineSection(context, ref, remindersState),
            const SizedBox(height: 20),

            // 6. Surgery Recovery & Milestone Card
            _buildRecoverySummaryCard(context, ref, recoveryState),
            const SizedBox(height: 20),

            // 7. Recent Test Reports Snapshot
            _buildRecentReportsSection(context, reportsState),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day,',
                  style: TextStyle(color: Color(0xFFD6EADF), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Vijay Sharma',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Post-Op Recovery · Day 8 of 28 Active',
                  style: TextStyle(color: Color(0xFFF3EDE0), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlertsSection(
      BuildContext context, WidgetRef ref, RemindersState remindersState) {
    final lowSupply = remindersState.lowSupplyMedicines;
    final nextTest = remindersState.upcomingTests.isNotEmpty
        ? remindersState.upcomingTests.first
        : null;

    return Column(
      children: [
        if (lowSupply.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medication Refill Alert (${lowSupply.length} low)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lowSupply.first.medicineName} has only ${lowSupply.first.daysOfSupplyRemaining} days of doses left.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => onNavigateTab(1), // Go to Reminders
                  child: const Text('Refill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        if (nextTest != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming: ${nextTest.testName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'In ${nextTest.daysUntilTest} days at ${nextTest.labOrClinicName}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => onNavigateTab(1),
                  child: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickModulesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Healthcare Modules',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModuleCard(
              icon: Icons.description_outlined,
              label: 'Test Reports\n& AI Insights',
              color: AppColors.primary,
              onTap: () => onNavigateTab(0),
            ),
            const SizedBox(width: 10),
            _buildModuleCard(
              icon: Icons.medication_outlined,
              label: 'Medicines\n& Refills',
              color: AppColors.accentBlue,
              onTap: () => onNavigateTab(1),
            ),
            const SizedBox(width: 10),
            _buildModuleCard(
              icon: Icons.healing_outlined,
              label: 'Surgery Care\n& Diet Plan',
              color: AppColors.accentAmber,
              onTap: () => onNavigateTab(3),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildModuleCard(
              icon: Icons.family_restroom_rounded,
              label: 'Family\nConnect',
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
            const SizedBox(width: 10),
            _buildModuleCard(
              icon: Icons.calendar_month_outlined,
              label: 'Book Lab\nTests',
              color: AppColors.accentTeal,
              onTap: () => onNavigateTab(4),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
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
      ),
    );
  }

  Widget _buildTodayMedicineSection(
      BuildContext context, WidgetRef ref, RemindersState remindersState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alarm_on_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Today's Medication Doses",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...remindersState.medicines.expand((med) {
            return med.dailySchedules.map((schedule) {
              return _buildDoseItemTile(context, ref, med, schedule);
            });
          }).take(3),
        ],
      ),
    );
  }

  Widget _buildDoseItemTile(BuildContext context, WidgetRef ref,
      MedicineReminder med, DoseSchedule schedule) {
    final isTaken = schedule.status == AdherenceStatus.taken;
    final isSkipped = schedule.status == AdherenceStatus.skipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTaken
            ? AppColors.successSurface
            : (isSkipped ? AppColors.errorSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTaken
              ? AppColors.success.withOpacity(0.3)
              : (isSkipped ? AppColors.error.withOpacity(0.3) : AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_liquid_rounded,
            size: 20,
            color: isTaken
                ? AppColors.success
                : (isSkipped ? AppColors.error : AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  '${schedule.timeString} · ${med.dosage} (${med.instructions})',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isTaken && !isSkipped) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                ref.read(remindersProvider.notifier).markDoseTaken(
                      medicineId: med.id,
                      timeOfDay: schedule.timeOfDay,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged ${med.medicineName} as Taken!')),
                );
              },
              child: const Text('Taken', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                ref.read(remindersProvider.notifier).markDoseSkipped(
                      medicineId: med.id,
                      timeOfDay: schedule.timeOfDay,
                    );
              },
              child: const Text('Skip', style: TextStyle(fontSize: 11)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isTaken ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isTaken ? 'TAKEN' : 'SKIPPED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoverySummaryCard(
      BuildContext context, WidgetRef ref, RecoveryDietState recoveryState) {
    final plan = recoveryState.recoveryPlan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.healing_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Surgery Recovery Protocol',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Day ${plan.currentDay} of ${plan.totalRecoveryDays}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.procedureName,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progressFraction,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Care: ${recoveryState.completedTasksCount} / ${recoveryState.totalTasksCount} tasks done',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => onNavigateTab(3),
                child: const Text(
                  'Open Checklist →',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsSection(
      BuildContext context, ReportsState reportsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Lab Reports',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => onNavigateTab(0),
              child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...reportsState.reports.take(2).map((report) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(report.reportDate),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.labProvider} · ${report.doctorName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  report.summaryPlainLanguage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
