import sys
import re

file_path = 'lib/core/services/notification_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add flutter_timezone import
content = content.replace('import \'package:timezone/data/latest.dart\' as tz_data;', 'import \'package:timezone/data/latest.dart\' as tz_data;\nimport \'package:flutter_timezone/flutter_timezone.dart\';')

# Update initialize
init_replacement = '''  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();
    // FIX FOR L5: Read the actual local timezone from the device instead of relying on UTC offsets
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationService] Failed to set timezone: \x24e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');'''

content = content.replace('''  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');''', init_replacement)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
