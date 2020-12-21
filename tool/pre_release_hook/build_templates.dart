#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

void main() {
  final templatePath = join(
      Script.current.pathToProjectRoot, 'lib', 'src', 'assets', 'templates');

  final expanderPath = join(Script.current.pathToProjectRoot, 'lib', 'src',
      'templates', 'expander.dart');

  final expanders = <String>[];

  final content = StringBuffer('''
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

''');

  find('*', root: templatePath).forEach((file) {
    content.write('''
\t\t// ignore: non_constant_identifier_names
\t\tvoid ${buildMethodName(file)}() {
      final expandTo = join(targetPath, '${basename(file)}');
       // ignore: unnecessary_raw_strings
       expandTo.write(r\'\'\'
${read(file).toList().join('\n')}\'\'\');
    }

''');

    expanders.add('\t\t\t${buildMethodName(file)}();\n');
  });

  content.write('''
\t\tvoid expand() {
''');

  for (final expander in expanders) {
    content.write(expander);
  }
  content.write('''
  }
''');

  content.write('''
}''');

  if (!exists(dirname(expanderPath))) {
    createDir(dirname(expanderPath));
  }
  expanderPath.write(content.toString());
}

String buildMethodName(String file) {
  var _file = file;
  if (_file.endsWith('.template')) {
    _file = basenameWithoutExtension(_file);
  }

  return basenameWithoutExtension(_file);
}
