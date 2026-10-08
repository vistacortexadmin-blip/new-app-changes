import sys

file_path = 'lib/main.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

init_app_check = '''    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FIX FOR M2: Turn on App Check to secure backend resources
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );'''

content = content.replace('''    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );''', init_app_check)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
