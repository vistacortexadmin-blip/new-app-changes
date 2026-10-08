import sys
import re

file_path = 'lib/features/security/views/security_audit_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
imports = '''import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
'''
content = content.replace('import \'package:flutter/services.dart\';', 'import \'package:flutter/services.dart\';\n' + imports)

# First Clipboard copy for single event
replacement1 = '''                    onPressed: () async {
                      final tempDir = await getTemporaryDirectory();
                      final file = File('\x24{tempDir.path}/audit_event_\x24{event.id}.json');
                      await file.writeAsString(event.toJson());
                      await Share.shareXFiles([XFile(file.path)], text: 'Audit Event Proof');
                      if (context.mounted) Navigator.pop(context);
                    },'''
content = re.sub(r'onPressed:\s*\(\)\s*\{\s*final tempDir = await getTemporaryDirectory\(\).*?if \(context\.mounted\) Navigator\.pop\(context\);\s*\},', replacement1, content, flags=re.DOTALL)
content = re.sub(r'onPressed:\s*\(\)\s*\{\s*Clipboard\.setData\(ClipboardData\(text:\s*event\.toJson\(\)\)\);\s*Navigator\.pop\(context\);\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(.*?\);\s*\},', replacement1, content, flags=re.DOTALL)

# Second Clipboard copy for full export
replacement2 = '''              onPressed: () async {
                final jsonPkg = _auditService.exportAuditPackage();
                final tempDir = await getTemporaryDirectory();
                final file = File('\x24{tempDir.path}/full_audit_package.json');
                await file.writeAsString(jsonPkg);
                await Share.shareXFiles([XFile(file.path)], text: 'Compliance Audit Package');
              },'''
content = re.sub(r'onPressed:\s*\(\)\s*\{\s*final jsonPkg = _auditService\.exportAuditPackage\(\);\s*final tempDir = await getTemporaryDirectory\(\);.*?await Share\.shareXFiles.*?\},', replacement2, content, flags=re.DOTALL)
content = re.sub(r'onPressed:\s*\(\)\s*\{\s*final jsonPkg = _auditService\.exportAuditPackage\(\);\s*Clipboard\.setData\(ClipboardData\(text:\s*jsonPkg\)\);\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(.*?\);\s*\},', replacement2, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
