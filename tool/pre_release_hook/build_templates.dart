#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';

String newVersion;
void main(List<String> args) {
  newVersion = args[0];

  print(green('Running build_templates with version: $newVersion'));
  final templatePath = join(
      Script.current.pathToProjectRoot, 'lib', 'src', 'assets', 'templates');

  final expanderPath = join(Script.current.pathToProjectRoot, 'lib', 'src',
      'templates', 'expander.dart');

  final content = packAssets(templatePath);

  if (!exists(dirname(expanderPath))) {
    createDir(dirname(expanderPath));
  }

  print('Writing assets to $expanderPath');
  expanderPath.write(content);
}

/// We create a dart library with a single class TemplateExpander which contains
/// a method for each asset.
/// The method contains a string which is the contents of the asset encoded as
/// a string.
///
/// At run time TemplateExpaner.expand() is called to
/// expand each of the assets.
String packAssets(String templatePath) {
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

  print('packing assets');
  find('*', workingDirectory: templatePath).forEach((file) {
    print('packing $file');

    /// Write the content of each asset into a method.
    content.write('''
\t\t// ignore: non_constant_identifier_names
\t\tvoid ${buildMethodName(file)}() {
      final expandTo = join(targetPath, '${basename(file)}');
       // ignore: unnecessary_raw_strings
       expandTo.write(r\'\'\'
${preprocess(file, read(file).toList()).join('\n')}\'\'\');
    }

''');

    expanders.add('\t\t\t${buildMethodName(file)}();\n');
  });

  /// Create the 'expand' method which when called will
  /// expanded each of the assets.
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

  return content.toString();
}

/// This method is called before each asset is written
/// into the expander. You can use this method to
/// modify the templates content before it is written to the exapnder.
List<String> preprocess(String file, List<String> lines) {
  final processed = <String>[];

  /// update the dcli version to match the version we are releasing.
  if (basename(file) == 'pubspec.yaml.template') {
    for (final line in lines) {
      if (line.contains('dcli:')) {
        final version = Version.parse(newVersion);
        processed.add('  dcli: ^${version.major}.${version.minor}.0');
      } else {
        processed.add(line);
      }
    }
  }

  return processed.isNotEmpty ? processed : lines;
}

String buildMethodName(String file) {
  var _file = file;
  if (_file.endsWith('.template')) {
    _file = basenameWithoutExtension(_file);
  }

  return basenameWithoutExtension(_file);
}
