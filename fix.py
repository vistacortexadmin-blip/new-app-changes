import sys
import re

file_path = 'lib/core/storage/seed_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('import \'../../features/family_connect/models/shared_activity_model.dart\';', '')
content = content.replace('static List<SharedActivityLog> get initialActivityLogs => [];', 'static List<dynamic> get initialActivityLogs => [];')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

file_path2 = 'lib/features/family_connect/providers/family_connect_provider.dart'
with open(file_path2, 'r', encoding='utf-8') as f:
    content2 = f.read()

content2 = content2.replace('SeedData.initialActivityLogs', '[]')

with open(file_path2, 'w', encoding='utf-8') as f:
    f.write(content2)

