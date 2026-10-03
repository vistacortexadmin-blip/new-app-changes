import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay on track with your health.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      icon: Icon(Icons.add, color: Theme.of(context).cardColor, size: 24),
                      onPressed: () {
                        if (_tabController.index == 2) {
                          _showAddTestModal(context);
                        } else {
                          _showAddMedicineModal(context);
                        }
                      },
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
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  _buildTestsTab(context),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
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
                      strokeCap: StrokeCap.round,
                      backgroundColor: Theme.of(context).dividerColor,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Adherence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep up the great work! Consistency is key.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                      style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.dosage,
                      style: TextStyle(fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
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

  void _showAddMedicineModal(BuildContext context) async {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final supplyController = TextEditingController();
    Map<DoseTimeOfDay, TimeOfDay> selectedDoses = {
      DoseTimeOfDay.morning: const TimeOfDay(hour: 8, minute: 0)
    };
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              child: SingleChildScrollView(
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
                      controller: supplyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Total Supply/Pills (e.g., 30)'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Start Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Times of Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DoseTimeOfDay.values.map((time) {
                        final isSelected = selectedDoses.containsKey(time);
                        return FilterChip(
                          label: Text(time.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                if (time == DoseTimeOfDay.morning) {
                                  selectedDoses[time] = const TimeOfDay(hour: 8, minute: 0);
                                } else if (time == DoseTimeOfDay.afternoon) {
                                  selectedDoses[time] = const TimeOfDay(hour: 13, minute: 0);
                                } else if (time == DoseTimeOfDay.evening) {
                                  selectedDoses[time] = const TimeOfDay(hour: 20, minute: 0);
                                } else {
                                  selectedDoses[time] = const TimeOfDay(hour: 22, minute: 0);
                                }
                              } else {
                                if (selectedDoses.length > 1) {
                                  selectedDoses.remove(time);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: selectedDoses.keys.map((time) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${time.name} Time: ${selectedDoses[time]!.format(context)}'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedDoses[time]!,
                            );
                            if (pickedTime != null) {
                              setModalState(() {
                                selectedDoses[time] = pickedTime;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty || selectedDoses.isEmpty) {
                            return; // Silently return if invalid to avoid context crashes
                          }

                          final reminder = MedicineReminder(
                            id: const Uuid().v4(),
                            medicineName: nameController.text,
                            dosage: dosageController.text,
                            instructions: '',
                            prescribedFor: '',
                            dailySchedules: selectedDoses.entries.map((e) => DoseSchedule(
                              timeOfDay: e.key,
                              timeString: e.value.format(context),
                            )).toList(),
                            totalQuantityAvailable: int.tryParse(supplyController.text) ?? 30,
                            dailyDoseCount: selectedDoses.length,
                            startDate: selectedDate,
                            durationDays: 30,
                          );

                          ref
                              .read(remindersProvider.notifier)
                              .addMedicineReminder(reminder);

                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Save Reminder'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    dosageController.dispose();
    supplyController.dispose();
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLow ? AppColors.warning : Theme.of(context).dividerColor,
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
                      style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLow ? AppColors.warning.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$daysLeft Days Left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isLow ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Medicine?'),
                              content: Text('Are you sure you want to permanently delete ${med.medicineName}? All its scheduled alarms will be cancelled.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ref.read(remindersProvider.notifier).deleteMedicine(med.id);
                                  }, 
                                  child: const Text('Delete', style: TextStyle(color: Colors.red))
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Current Stock: ${med.totalQuantityAvailable} pills',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _showEditStockModal(context, med);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.edit, size: 16, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              if (isLow) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRefillModal(context, med);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Refill Supply'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showRefillModal(BuildContext context, MedicineReminder med) {
    int selectedAmount = 30;
    final customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  Text('Refill ${med.medicineName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Select amount to add:', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [10, 30, 60, 90].map((amount) {
                      return ChoiceChip(
                        label: Text('+$amount', style: TextStyle(color: selectedAmount == amount ? Colors.white : AppColors.primary)),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        selected: selectedAmount == amount,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedAmount = amount;
                              customController.clear();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Or enter custom amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setModalState(() {
                          selectedAmount = int.tryParse(val) ?? 0;
                        });
                      } else {
                        setModalState(() {
                          selectedAmount = 30;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAmount <= 0 ? null : () {
                        ref.read(remindersProvider.notifier).refillStock(
                          medicineId: med.id,
                          addedQuantity: selectedAmount,
                        );
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Add $selectedAmount Pills', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showEditStockModal(BuildContext context, MedicineReminder med) {
    final customController = TextEditingController(text: med.totalQuantityAvailable.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              Text('Edit Stock: ${med.medicineName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Enter the exact number of pills you currently have:', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 16),
              TextField(
                controller: customController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Current Total Pills',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final exactAmount = int.tryParse(customController.text) ?? med.totalQuantityAvailable;
                    ref.read(remindersProvider.notifier).updateStock(
                      medicineId: med.id,
                      exactQuantity: exactAmount,
                    );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: Tests
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildTestsTab(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final upcomingTests = state.nextTests.where((test) => !test.isCompleted).toList();

    if (upcomingTests.isEmpty) {
      return const Center(child: Text("No upcoming tests. Add one using the + button."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: upcomingTests.length,
      itemBuilder: (context, index) {
        final test = upcomingTests[index];
        final formattedDate = DateFormat('MMM d, yyyy').format(test.scheduledDate);
        
        final now = DateTime.now();
        final testDate = DateTime(test.scheduledDate.year, test.scheduledDate.month, test.scheduledDate.day);
        final today = DateTime(now.year, now.month, now.day);
        final daysUntil = testDate.difference(today).inDays;
        
        String daysUntilStr;
        if (daysUntil < 0) {
          daysUntilStr = "Overdue";
        } else if (daysUntil == 0) {
          daysUntilStr = "Today";
        } else if (daysUntil == 1) {
          daysUntilStr = "Tomorrow";
        } else {
          daysUntilStr = "In $daysUntil days";
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                
                // Middle details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.testName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        test.labOrClinicName,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right status and button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: daysUntil < 0 ? AppColors.warning.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            daysUntilStr,
                            style: TextStyle(
                              color: daysUntil < 0 ? AppColors.warning : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Test?'),
                                content: Text('Are you sure you want to permanently delete the test "${test.testName}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ref.read(remindersProvider.notifier).deleteTest(test.id);
                                    }, 
                                    child: const Text('Delete', style: TextStyle(color: Colors.red))
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        ref.read(remindersProvider.notifier).markNextTestCompleted(test.id);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('Done', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTestModal(BuildContext context) {
    final nameController = TextEditingController();
    final labController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Test Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: labController,
                      decoration: const InputDecoration(labelText: 'Lab/Clinic'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(selectedDate == null ? 'Select Date' : DateFormat('MMM d, yyyy').format(selectedDate!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setModalState(() => selectedTime = time);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty || selectedDate == null || selectedTime == null) {
                            return;
                          }
                          
                          final scheduledDate = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          final newTest = NextTestReminder(
                            id: const Uuid().v4(),
                            testName: nameController.text,
                            labOrClinicName: labController.text,
                            scheduledDate: scheduledDate,
                            preparationInstructions: '',
                            isCompleted: false,
                          );

                          ref.read(remindersProvider.notifier).addNextTestReminder(newTest);
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Save Test'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
