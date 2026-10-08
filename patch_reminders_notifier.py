import sys
import re

file_path = 'lib/features/reminders/providers/reminders_provider.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

imports = '''import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
'''

content = content.replace('import \'../../../core/storage/seed_data.dart\';', imports + 'import \'../../../core/storage/seed_data.dart\';')

# Add _saveState
save_state = '''  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final medsJson = state.medicines.map((m) => m.toJson()).toList();
    final testsJson = state.nextTests.map((t) => t.toJson()).toList();
    await prefs.setString('reminders_medicines', jsonEncode(medsJson));
    await prefs.setString('reminders_tests', jsonEncode(testsJson));
  }
'''

# Add _loadState
load_state = '''  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medsStr = prefs.getString('reminders_medicines');
      final testsStr = prefs.getString('reminders_tests');
      
      List<MedicineReminder> loadedMeds = SeedData.initialReminders;
      List<NextTestReminder> loadedTests = SeedData.initialNextTests;
      
      if (medsStr != null) {
        final decodedMeds = jsonDecode(medsStr) as List;
        loadedMeds = decodedMeds.map((m) => MedicineReminder.fromJson(m)).toList();
      }
      if (testsStr != null) {
        final decodedTests = jsonDecode(testsStr) as List;
        loadedTests = decodedTests.map((t) => NextTestReminder.fromJson(t)).toList();
      }
      
      state = state.copyWith(medicines: loadedMeds, nextTests: loadedTests);
    } catch (e) {
      if (kDebugMode) debugPrint('[RemindersNotifier] Error loading state: \x24e');
    }
  }
'''

# Hook _loadState into constructor
constructor = '''  RemindersNotifier()
      : super(RemindersState(
          medicines: SeedData.initialReminders,
          nextTests: SeedData.initialNextTests,
        )) {
    _loadState();
  }
'''

content = re.sub(r'  RemindersNotifier\(\)\s*: super\(RemindersState\(\s*medicines: SeedData\.initialReminders,\s*nextTests: SeedData\.initialNextTests,\s*\)\);', constructor + '\n' + save_state + '\n' + load_state, content, flags=re.DOTALL)

# Hook _saveState into all methods that mutate state
# They all do: state = state.copyWith(...);
# We can just replace that with: state = state.copyWith(...); _saveState();
content = re.sub(r'(state = state\.copyWith\([^;]+;\))', r'\1 _saveState();', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
