import sys

file_path = 'lib/core/storage/seed_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('import \'../../features/recovery_care/models/recovery_model.dart\';\n', '')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
