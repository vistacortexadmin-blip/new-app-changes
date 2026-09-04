import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../providers/reminders_provider.dart';
import '../models/reminder_model.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remindersState = ref.watch(remindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Medicines & Reminders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: "Today's Doses (${remindersState.pendingDosesTodayCount})"),
            Tab(text: "Refills (${remindersState.lowSupplyMedicines.length})"),
            const Tab(text: "Next Tests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyDosesTab(context, remindersState),
          _buildRefillSupplyTab(context, remindersState),
          _buildNextTestsTab(context, remindersState),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddMedicineModal(context),
      ),
    );
  }

  Widget _buildDailyDosesTab(BuildContext context, RemindersState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTimeFilterChip('Morning', DoseTimeOfDay.morning, state.selectedTimeFilter),
              const SizedBox(width: 8),
              _buildTimeFilterChip('Afternoon', DoseTimeOfDay.afternoon, state.selectedTimeFilter),
              const SizedBox(width: 8),
              _buildTimeFilterChip('Night', DoseTimeOfDay.night, state.selectedTimeFilter),
            ],
          ),
          const SizedBox(height: 16),

          ...state.medicines.map((med) {
            final schedule = med.dailySchedules.firstWhere(
              (s) => s.timeOfDay == state.selectedTimeFilter,
              orElse: () => DoseSchedule(timeOfDay: state.selectedTimeFilter, timeString: ''),
            );

            if (schedule.timeString.isEmpty) return const SizedBox.shrink();

            final isTaken = schedule.status == AdherenceStatus.taken;
            final isSkipped = schedule.status == AdherenceStatus.skipped;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isTaken
                      ? AppColors.success.withOpacity(0.4)
                      : (isSkipped ? AppColors.error.withOpacity(0.4) : AppColors.border),
                  width: isTaken || isSkipped ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          med.medicineName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule.timeString,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosage: ${med.dosage} · ${med.instructions}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    'Prescribed For: ${med.prescribedFor}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const Divider(height: 24, color: AppColors.divider),

                  if (isTaken)
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Taken today at ${DateFormat('hh:mm a').format(schedule.loggedAt ?? DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    )
                  else if (isSkipped)
                    Row(
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Skipped (${schedule.skipReason ?? "Patient choice"})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Mark as Taken'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              ref.read(remindersProvider.notifier).markDoseTaken(
                                    medicineId: med.id,
                                    timeOfDay: schedule.timeOfDay,
                                  );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Skip Dose'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              _showSkipReasonDialog(context, med.id, schedule.timeOfDay);
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, DoseTimeOfDay time, DoseTimeOfDay current) {
    final isSelected = time == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(remindersProvider.notifier).setTimeFilter(time),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefillSupplyTab(BuildContext context, RemindersState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: AppColors.info, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'VistaCortex tracks your available tablet inventory and calculates exact days remaining before you run out.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...state.medicines.map((med) {
            final isLow = med.isLowSupply;
            final isCritical = med.isCriticalSupply;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCritical
                      ? AppColors.error
                      : (isLow ? AppColors.warning : AppColors.border),
                  width: isLow ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        med.medicineName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCritical
                              ? AppColors.errorSurface
                              : (isLow ? AppColors.warningSurface : AppColors.successSurface),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCritical
                              ? 'CRITICAL REFILL'
                              : (isLow ? 'LOW STOCK' : 'ADEQUATE'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCritical
                                ? AppColors.error
                                : (isLow ? AppColors.warning : AppColors.success),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Remaining: ${med.totalQuantityAvailable} pills',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        '~${med.daysOfSupplyRemaining} days left',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Expected Run-Out Date: ${DateFormat('dd MMMM yyyy').format(med.estimatedRefillDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLow ? AppColors.error : AppColors.textMuted,
                      fontWeight: isLow ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                      label: const Text('Record Refill (+30 Pills)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLow ? AppColors.primary : AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        ref.read(remindersProvider.notifier).refillStock(
                              medicineId: med.id,
                              addedQuantity: 30,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added +30 units to ${med.medicineName} inventory.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNextTestsTab(BuildContext context, RemindersState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled Diagnostic Follow-Ups',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...state.nextTests.map((test) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
                          test.testName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: test.isCompleted
                              ? AppColors.successSurface
                              : AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          test.isCompleted
                              ? 'COMPLETED'
                              : 'IN ${test.daysUntilTest} DAYS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: test.isCompleted ? AppColors.success : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lab: ${test.labOrClinicName}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    'Scheduled for: ${DateFormat('EEE, dd MMM yyyy').format(test.scheduledDate)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Prep: ${test.preparationInstructions}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  if (!test.isCompleted) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Mark as Done'),
                        onPressed: () {
                          ref
                              .read(remindersProvider.notifier)
                              .markNextTestCompleted(test.id);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSkipReasonDialog(
      BuildContext context, String medId, DoseTimeOfDay time) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Skip Dose Reason'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Fasting / Medical Procedure'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(remindersProvider.notifier).markDoseSkipped(
                        medicineId: medId,
                        timeOfDay: time,
                        reason: 'Fasting / Procedure',
                      );
                },
              ),
              ListTile(
                title: const Text('Experiencing Nausea or Side Effects'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(remindersProvider.notifier).markDoseSkipped(
                        medicineId: medId,
                        timeOfDay: time,
                        reason: 'Side Effects / Nausea',
                      );
                },
              ),
              ListTile(
                title: const Text('Forgot medication at home'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(remindersProvider.notifier).markDoseSkipped(
                        medicineId: medId,
                        timeOfDay: time,
                        reason: 'Not Available',
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMedicineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Prescription Medication',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: 'Medicine Name (e.g. Lisinopril)'),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Dose & Strength (e.g. 10mg - 1 Tablet)'),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Instructions (e.g. After breakfast)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prescription added to daily schedule!')),
                    );
                  },
                  child: const Text('Save Medication'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
