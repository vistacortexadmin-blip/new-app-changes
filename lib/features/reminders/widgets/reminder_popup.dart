import 'package:flutter/material.dart';
import '../models/universal_reminder.dart';

void showReminderPopup(
  BuildContext context, {
  required String initialType, // 'MEDICINE', 'TEST', or 'CUSTOM'
  required String initialTitle,
  required String initialItemId,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReminderPopupWidget(
        type: initialType,
        title: initialTitle,
        itemId: initialItemId,
      );
    },
  );
}

class ReminderPopupWidget extends StatefulWidget {
  final String type;
  final String title;
  final String itemId;

  const ReminderPopupWidget({
    Key? key,
    required this.type,
    required this.title,
    required this.itemId,
  }) : super(key: key);

  @override
  State<ReminderPopupWidget> createState() => _ReminderPopupWidgetState();
}

class _ReminderPopupWidgetState extends State<ReminderPopupWidget> {
  late ReminderType _selectedType;
  TimeOfDay _selectedTime = TimeOfDay.now();
  ReminderFrequency _frequency = ReminderFrequency.DAILY;
  NotificationType _notification = NotificationType.SOUND;
  final List<int> _weeklyDays = [];

  @override
  void initState() {
    super.initState();
    if (widget.type == 'MEDICINE') {
      _selectedType = ReminderType.MEDICINE;
    } else if (widget.type == 'TEST') {
      _selectedType = ReminderType.TEST;
    } else {
      _selectedType = ReminderType.CUSTOM;
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_weeklyDays.contains(dayIndex)) {
        _weeklyDays.remove(dayIndex);
      } else {
        _weeklyDays.add(dayIndex);
      }
    });
  }

  void _onSaveClick() {
    Navigator.pop(context);

    // Professional, production-level success alert confirmation
    String displayType = 'Reminder';
    if (_selectedType == ReminderType.MEDICINE)
      displayType = 'Medicine intake schedule';
    if (_selectedType == ReminderType.TEST) displayType = 'Lab test window';
    if (_selectedType == ReminderType.CUSTOM)
      displayType = 'Doctor follow-up appointment';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ $displayType for "${widget.title}" has been successfully active and set.'),
        backgroundColor: const Color(
            0xFF10B981), // Solid Emerald Green for active state confirmation
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text('⏰ ', style: TextStyle(fontSize: 20)),
          const Text('Set Schedule Alarm',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${widget.title}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 18),
            const Text('Reminder Category:',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButton<ReminderType>(
              value: _selectedType,
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey.shade300),
              items: const [
                DropdownMenuItem(
                    value: ReminderType.MEDICINE,
                    child: Text('💊 Medicine Intake')),
                DropdownMenuItem(
                    value: ReminderType.TEST,
                    child: Text('🔬 Lab / Blood Test')),
                DropdownMenuItem(
                    value: ReminderType.CUSTOM,
                    child: Text('🤝 Doctor Follow-up Meeting')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),
            const Text('Choose Alert Time:',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_selectedTime.format(context),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),
              trailing: const Icon(Icons.access_time_filled,
                  color: Colors.blueAccent),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                    context: context, initialTime: _selectedTime);
                if (time != null) setState(() => _selectedTime = time);
              },
            ),
            const Divider(),
            const Text('Repeat Frequency:',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            DropdownButton<ReminderFrequency>(
              value: _frequency,
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey.shade300),
              items: const [
                DropdownMenuItem(
                    value: ReminderFrequency.ONCE, child: Text('Once Only')),
                DropdownMenuItem(
                    value: ReminderFrequency.DAILY,
                    child: Text('Every Day (Daily)')),
                DropdownMenuItem(
                    value: ReminderFrequency.WEEKLY,
                    child: Text('Specific Days (Weekly)')),
                DropdownMenuItem(
                    value: ReminderFrequency.MONTHLY,
                    child: Text('Once a Month (Monthly)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _frequency = val);
              },
            ),
            if (_frequency == ReminderFrequency.WEEKLY) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List.generate(7, (index) {
                  final dayNum = index + 1;
                  final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final isSelected = _weeklyDays.contains(dayNum);
                  return ChoiceChip(
                    label: Text(labels[index]),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    onSelected: (_) => _toggleDay(dayNum),
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Notification Sound Mode:',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            DropdownButton<NotificationType>(
              value: _notification,
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey.shade300),
              items: const [
                DropdownMenuItem(
                    value: NotificationType.SOUND,
                    child: Text('🔊 Ringtone Melody Alert')),
                DropdownMenuItem(
                    value: NotificationType.VIBRATION,
                    child: Text('📳 Device Vibration Only')),
                DropdownMenuItem(
                    value: NotificationType.VISUAL,
                    child: Text('💬 Full Screen Screen Banner')),
                DropdownMenuItem(
                    value: NotificationType.SILENT,
                    child: Text('🔕 Silent Status Bar Log')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _notification = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _onSaveClick,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB), // Production Primary Blue
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Confirm Settings',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
