#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

void main() {
  var templatePath = join(
      Script.current.pathToProjectRoot, 'lib', 'src', 'assets', 'templates');

  var expanderPath = join(Script.current.pathToProjectRoot, 'lib', 'src',
      'templates', 'expander.dart');

  var expanders = <String>[];

  var content = '''
import 'package:dcli/dcli.dart';

/// GENERATED -- GENERATED
/// 
/// DO NOT MODIFIY
/// 
/// This script is generated via tool/build_templates.dart which is
/// called by pub_release (whicih runs any scripts in the  tool/pre_release_hook directory)
/// 
/// GENERATED - GENERATED

class TemplateExpander {
    String targetPath;
    TemplateExpander(this.targetPath);

''';

  find('*', root: templatePath).forEach((file) {
    content += '''\t\tvoid ${buildMethodName(file)}() {
      var expandTo = join(targetPath, '${basename(file)}');
       expandTo.write(r\'\'\'${read('$file').toList().join('\n')}\'\'\');
    }

''';

    expanders.add('\t\t\t${buildMethodName(file)}();\n');
  });

  content += '''\t\tvoid expand() {
''';

  for (var expander in expanders) {
    content += expander;
  }
  content += '''
  }
''';

  content += '''
}''';

  if (!exists(dirname(expanderPath))) {
    createDir(dirname(expanderPath));
  }
  expanderPath.write(content);
}

String buildMethodName(String file) {
  if (file.endsWith('.template')) {
    file = basenameWithoutExtension(file);
  }

  return basenameWithoutExtension(file);
}
