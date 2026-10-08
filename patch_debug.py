import os
import re

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = re.sub(r'(?<!if \(kDebugMode\) )debugPrint\(', r'if (kDebugMode) debugPrint(', content)
            
            if new_content != content:
                if 'package:flutter/foundation.dart' not in new_content:
                    new_content = 'import \'package:flutter/foundation.dart\';\n' + new_content
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
