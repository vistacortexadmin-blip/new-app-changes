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

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  String _selectedFilter = 'All';
  bool _metforminActive = true;
  bool _vitaminDActive = true;
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
            // 1. Header with title, subtitle & circular '+' button matching Screen 6
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      onPressed: () => _showAddReminderDialog(context),
                      onPressed: () => _showAddMedicineModal(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. Filter chips matching Screen 6
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Medicines'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tests'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Follow-ups'),
                  _buildDailyDosesTab(context),
                  const Center(child: Text("Refills Tab (Coming Soon)")),
                  const Center(child: Text("Tests Tab (Coming Soon)")),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

            // 3. Reminders List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                children: [
                  // Item 1: Metformin with Switch
                  _buildSwitchReminderCard(
                    title: 'Take Metformin',
                    subtitle: '1 Tablet • After breakfast',
                    timeString: '8:00 AM',
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFFEC4899),
                    iconBgColor: const Color(0xFFFDF2F8),
                    isActive: _metforminActive,
                    onChanged: (val) {
                      setState(() {
                        _metforminActive = val;
                      });
                    },
                  ),
  Widget _buildDailyDosesTab(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final adherence = state.adherencePercentage;

                  // Item 2: Vitamin D3 with Switch
                  _buildSwitchReminderCard(
                    title: 'Vitamin D3',
                    subtitle: '1 Tablet • After lunch',
                    timeString: '1:00 PM',
                    icon: Icons.medication_liquid_rounded,
                    iconColor: const Color(0xFFF97316),
                    iconBgColor: const Color(0xFFFFF7ED),
                    isActive: _vitaminDActive,
                    onChanged: (val) {
                      setState(() {
                        _vitaminDActive = val;
                      });
                    },
                  ),

                  // Item 3: Blood Test (HbA1c) with Calendar button
                  _buildActionReminderCard(
                    title: 'Blood Test (HbA1c)',
                    subtitle: 'Follow-up test',
                    timeString: '15 Sep 2025',
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: const Color(0xFFEFF6FF),
                    actionIcon: Icons.calendar_today_outlined,
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Follow-up test confirmed on calendar.')),
                      );
                    },
                  ),

                  // Item 4: Doctor Follow-up with Bell button
                  _buildActionReminderCard(
                    title: 'Doctor Follow-up',
                    subtitle: 'Dr. Ramesh Kumar',
                    timeString: '20 Sep 2025',
                    icon: Icons.person_search_rounded,
                    iconColor: const Color(0xFF0D9488),
                    iconBgColor: const Color(0xFFF0FDFA),
                    actionIcon: Icons.notifications_active_outlined,
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doctor visit alert is enabled.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Encouragement Banner matching Screen 6
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
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
                          adherence >= 0.8 ? AppColors.success : AppColors.warning),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Consistency today,\nbetter health tomorrow.',
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
                            Icons.favorite_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 24,
                          ),
                        ),
                      ],
                    Center(
                      child: Text(
                        '${(adherence * 100).toInt()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                  ],
                ),
              ),
            ),
          ],
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Adherence',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text(
                        'Keep up the great work! Consistency is key.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              )
            ],
          ),
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
              _buildTimeFilterChip('Afternoon', DoseTimeOfDay.afternoon, state),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
  Widget _buildTimeFilterChip(String label, DoseTimeOfDay filterValue, RemindersState state) {
    final isSelected = state.selectedTimeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
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

  Widget _buildSwitchReminderCard({
    required String title,
    required String subtitle,
    required String timeString,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
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
      child: Row(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
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
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.dosage,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.timeString,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          if (schedule.status == AdherenceStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleSkip(med.id, schedule.timeOfDay),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(remindersProvider.notifier)
                          .markDoseTaken(medicineId: med.id, timeOfDay: schedule.timeOfDay);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Taken'),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ],
            )
          ],
          if (isTaken || isSkipped) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isTaken ? AppColors.successLight : AppColors.warningLight,
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
              ],
              ),
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
            if (isSkipped && schedule.skipReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Reason: ${schedule.skipReason}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              )
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildActionReminderCard({
    required String title,
    required String subtitle,
    required String timeString,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required IconData actionIcon,
    required VoidCallback onAction,
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
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          IconButton(
            icon: Icon(actionIcon, color: AppColors.primary, size: 22),
            onPressed: onAction,
          ),
        ],
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

  void _showAddReminderDialog(BuildContext context) {
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
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Medicine / Event Name')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Time (e.g. 08:00 AM)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder schedule saved!')),
                    );
                  },
                  child: const Text('Save Reminder'),
                ),
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
            ],
          ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Medicine',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Medicine Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosageController,
                    decoration:
                        const InputDecoration(labelText: 'Dosage (e.g., 500mg)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                        labelText: 'Time (e.g. 08:00 AM)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DoseTimeOfDay>(
                    value: selectedTime,
                    decoration: const InputDecoration(labelText: 'Time of Day'),
                    items: DoseTimeOfDay.values.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text(time.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedTime = val);
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
                          totalQuantityAvailable: 30, // Default stock
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
}
