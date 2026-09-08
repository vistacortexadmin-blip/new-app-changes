import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/app_colors.dart';
import '../models/reminder_model.dart';
import '../providers/reminders_provider.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title, subtitle & circular '+' button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Stay on track with your health.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
                      onPressed: () => _showAddMedicineModal(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // TabBar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Doses'),
                Tab(text: 'Refills'),
                Tab(text: 'Tests'),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyDosesTab(context),
                  _buildRefillSupplyTab(context),
                  _buildUpcomingTestsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 1: Daily Doses
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildDailyDosesTab(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final adherence = state.adherencePercentage;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Adherence Ring
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: adherence,
                      strokeWidth: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        adherence >= 0.8
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(adherence * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Adherence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep up the great work! Consistency is key.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTimeFilterChip('Morning', DoseTimeOfDay.morning, state),
              const SizedBox(width: 8),
              _buildTimeFilterChip(
                  'Afternoon', DoseTimeOfDay.afternoon, state),
              const SizedBox(width: 8),
              _buildTimeFilterChip('Evening', DoseTimeOfDay.evening, state),
              const SizedBox(width: 8),
              _buildTimeFilterChip('Night', DoseTimeOfDay.night, state),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Medicines List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _buildMedicineCards(state),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Time-of-day filter chip
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildTimeFilterChip(
      String label, DoseTimeOfDay filterValue, RemindersState state) {
    final isSelected = state.selectedTimeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        ref.read(remindersProvider.notifier).setTimeFilter(filterValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
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

  // ──────────────────────────────────────────────────────────────────────────
  // Medicine cards list builder
  // ──────────────────────────────────────────────────────────────────────────

  List<Widget> _buildMedicineCards(RemindersState state) {
    List<Widget> cards = [];
    final selectedTime = state.selectedTimeFilter;

    for (var med in state.medicines) {
      for (var schedule in med.dailySchedules) {
        if (schedule.timeOfDay == selectedTime) {
          cards.add(_buildMedicineCard(med, schedule));
          cards.add(const SizedBox(height: 12));
        }
      }
    }

    if (cards.isEmpty) {
      cards.add(const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No medicines scheduled for this time.'),
        ),
      ));
    }

    return cards;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Individual medicine card
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMedicineCard(MedicineReminder med, DoseSchedule schedule) {
    bool isTaken = schedule.status == AdherenceStatus.taken;
    bool isSkipped = schedule.status == AdherenceStatus.skipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.medicineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.dosage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.timeString,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons for pending doses
          if (schedule.status == AdherenceStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _handleSkip(med.id, schedule.timeOfDay),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(remindersProvider.notifier).markDoseTaken(
                            medicineId: med.id,
                            timeOfDay: schedule.timeOfDay,
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Taken'),
                  ),
                ),
              ],
            ),
          ],

          // Status banner for taken / skipped
          if (isTaken || isSkipped) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isTaken
                    ? AppColors.successSurface
                    : AppColors.warningSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isTaken ? 'Dose Taken' : 'Dose Skipped',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTaken ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ),
            if (isSkipped && schedule.skipReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Reason: ${schedule.skipReason}',
                style: const TextStyle(
                    fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Skip dialog
  // ──────────────────────────────────────────────────────────────────────────

  void _handleSkip(String medId, DoseTimeOfDay timeOfDay) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Skip Reason'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'E.g., Felt nauseous, Forgot, etc.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(remindersProvider.notifier).markDoseSkipped(
                      medicineId: medId,
                      timeOfDay: timeOfDay,
                      reason: controller.text.isNotEmpty
                          ? controller.text
                          : 'Patient elected to skip',
                    );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Add Medicine Modal
  // ──────────────────────────────────────────────────────────────────────────

  void _showAddMedicineModal(BuildContext context) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController();
    DoseTimeOfDay selectedTime = DoseTimeOfDay.morning;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Medicine',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Medicine Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 500mg)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                        labelText: 'Time (e.g. 08:00 AM)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DoseTimeOfDay>(
                    initialValue: selectedTime,
                    decoration:
                        const InputDecoration(labelText: 'Time of Day'),
                    items: DoseTimeOfDay.values.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text(time.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedTime = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            timeController.text.isEmpty) {
                          return;
                        }

                        final reminder = MedicineReminder(
                          id: const Uuid().v4(),
                          medicineName: nameController.text,
                          dosage: dosageController.text,
                          instructions: '',
                          prescribedFor: '',
                          dailySchedules: [
                            DoseSchedule(
                              timeOfDay: selectedTime,
                              timeString: timeController.text,
                            )
                          ],
                          totalQuantityAvailable: 30,
                          dailyDoseCount: 1,
                          startDate: DateTime.now(),
                          durationDays: 30,
                        );

                        ref
                            .read(remindersProvider.notifier)
                            .addMedicineReminder(reminder);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reminder schedule saved!')),
                        );
                      },
                      child: const Text('Save Reminder'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 2: Refill Supply
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildRefillSupplyTab(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final medicines = state.medicines;

    if (medicines.isEmpty) {
      return const Center(child: Text('No medicines found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        final daysLeft = med.daysOfSupplyRemaining;
        final isLow = med.isLowSupply;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLow ? AppColors.warning : AppColors.border,
              width: isLow ? 2 : 1,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLow
                          ? AppColors.warningSurface
                          : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$daysLeft Days Left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isLow ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current Stock: ${med.totalQuantityAvailable} pills',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              if (isLow) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(remindersProvider.notifier).refillStock(
                            medicineId: med.id,
                            addedQuantity: 30,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Ordered 30 day refill!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('+30 Refill'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: Upcoming Diagnostic Tests
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildUpcomingTestsTab(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final tests = state.nextTests;

    if (tests.isEmpty) {
      return const Center(child: Text('No upcoming diagnostic tests scheduled.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        final daysUntil = test.daysUntilTest;
        final isCompleted = test.isCompleted;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.border
                  : (test.isOverdue ? AppColors.error : AppColors.primary),
              width: isCompleted ? 1 : 1.5,
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
                      test.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successSurface
                          : (test.isOverdue
                              ? AppColors.errorSurface
                              : AppColors.primarySurface),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Completed'
                          : (test.isOverdue
                              ? 'Overdue'
                              : 'In $daysUntil Days'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AppColors.success
                            : (test.isOverdue
                                ? AppColors.error
                                : AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      test.labOrClinicName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        test.preparationInstructions,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(remindersProvider.notifier)
                          .markNextTestCompleted(test.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${test.testName} marked as completed!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Mark Completed'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

