import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  String _selectedFilter = 'All';
  bool _metforminActive = true;
  bool _vitaminDActive = true;

  @override
  Widget build(BuildContext context) {
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
            // 1. Header with title, subtitle & circular '+' button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay on track with your health.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Medicines', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Tests', isDark, cardBg, borderColor, textSecondary),
                  const SizedBox(width: 8),
                  _buildFilterChip('Follow-ups', isDark, cardBg, borderColor, textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 14),

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
                    iconBgColor: isDark ? const Color(0xFF50123C) : const Color(0xFFFDF2F8),
                    isActive: _metforminActive,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
                    onChanged: (val) {
                      setState(() {
                        _metforminActive = val;
                      });
                    },
                  ),

                  // Item 2: Vitamin D3 with Switch
                  _buildSwitchReminderCard(
                    title: 'Vitamin D3',
                    subtitle: '1 Tablet • After lunch',
                    timeString: '1:00 PM',
                    icon: Icons.medication_liquid_rounded,
                    iconColor: const Color(0xFFF97316),
                    iconBgColor: isDark ? const Color(0xFF43281C) : const Color(0xFFFFF7ED),
                    isActive: _vitaminDActive,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
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
                    iconBgColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                    actionIcon: Icons.calendar_today_outlined,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
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
                    iconBgColor: isDark ? const Color(0xFF134E4A) : const Color(0xFFF0FDFA),
                    actionIcon: Icons.notifications_active_outlined,
                    cardBg: cardBg,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    isDark: isDark,
                    onAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doctor visit alert is enabled.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Encouragement Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2E1065) : const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF7C3AED).withValues(alpha: 0.4) : const Color(0xFFDDD6FE),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consistency today,\nbetter health tomorrow.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                            height: 1.3,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF4C1D95) : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
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

  Widget _buildSwitchReminderCard({
    required String title,
    required String subtitle,
    required String timeString,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isActive,
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
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
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required bool isDark,
    required VoidCallback onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(actionIcon, color: AppColors.primary, size: 22),
            onPressed: onAction,
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;

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
              Text('Add Reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
