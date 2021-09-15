#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart' as pub;

late String newVersion;
void main(List<String> args) {
  if (args.isEmpty) {
    print('Please provide the new version no.');
    exit(-1);
  }
  newVersion = args[0];

  print(green('Running build_templates with version: $newVersion'));
  final templatePath = join(
    DartProject.self.pathToProjectRoot,
    'lib',
    'src',
    'assets',
    'templates',
  );

  final expanderPath = join(
    DartProject.self.pathToProjectRoot,
    'lib',
    'src',
    'templates',
    'expander.dart',
  );

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

  final content = StringBuffer(
    '''
// ignore: prefer_relative_imports
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
    
    /// Creates a template expander that will expand its files int [targetPath]
    TemplateExpander(this.targetPath);

    /// The path the templates will be expanded into.
    String targetPath;

''',
  );

  print('packing assets');
  find('*', workingDirectory: templatePath).forEach((file) {
    print('packing $file');

    /// Write the content of each asset into a method.
    content.write(
      '''
\t\t/// Expander for ${buildMethodName(file)}
\t\t// ignore: non_constant_identifier_names
\t\tvoid ${buildMethodName(file)}() {
      join(targetPath, '${basename(file)}').write(
          // ignore: unnecessary_raw_strings    
         r\'\'\'
${preprocess(file, read(file).toList()).join('\n')}\'\'\',);
    }

''',
    );

    expanders.add('\t\t\t${buildMethodName(file)}();\n');
  });

  /// Create the 'expand' method which when called will
  /// expanded each of the assets.
  content.write(
    '''
/// Expand all templates.
\t\tvoid expand() {
''',
  );

  expanders.forEach(content.write);
  content
    ..write(
      '''
  }
''',
    )
    ..write(
      '''
}''',
    );

  return content.toString();
}

/// This method is called before each asset is written
/// into the expander. You can use this method to
/// modify the templates content before it is written to the exapnder.
List<String> preprocess(String file, List<String> lines) {
  final processed = <String>[];

  /// update the dcli version to match the version we are releasing.
  if (basename(file) == 'pubspec.yaml.template') {
    final pubspec = PubSpec.fromFile(DartProject.self.pathToPubSpec);

    String? section;
    for (final line in lines) {
      if (!line.startsWith(' ')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          section = parts[0];
        }
      }

      var modified = false;

      if (section == 'dependencies') {
        if (line.contains('dcli:')) {
          final version = Version.parse(newVersion);
          modified = true;
          processed.add('  dcli: ^${version.major}.${version.minor}.0');
        } else {
          final parts = line.split(':');
          if (parts.length == 2) {
            final package = parts[0].trim();
            final version = _packageVersion(pubspec, package);

            if (version != null) {
              processed.add('  $package: $version');
              modified = true;
            }
          }
        }
      }

      if (!modified) {
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

//  // ignore: non_constant_identifier_names
//   void pubspec() {
//     final _pubspec = PubSpec.fromScript(Script.current);

//     final dcliVersion = _pubspec.version;
//     if (dcliVersion == null) {
//       throw DCliException(
//           'Unable to obtain the dcli version from its pubspec.yaml file.');
//     }

//     final major = dcliVersion.major;
//     var minor = dcliVersion.minor;
//     var patch = dcliVersion.patch;

//     final argsVersion = _packageVersion(_pubspec, 'args');

//     final pathVersion = _packageVersion(_pubspec, 'path');

//     if (major == 0) {
//       patch = 0;
//     } else {
//       patch = 0;
//       minor = 0;
//     }
//     join(targetPath, 'pubspec.yaml.template').write('''
// name: %scriptname%
// version: 0.0.1
// description: A script generated by dcli.
// environment:
//   sdk: '>=2.12.0 <3.0.0'
// dependencies:
//   args: $argsVersion
//   dcli: ^$major.$minor.$patch
//   path: $pathVersion

// dev_dependencies:
//   pedantic: ^1.0.0
// ''');
//   }

String? _packageVersion(PubSpec _pubspec, String package) {
  final argsDep = _pubspec.dependencies[package];
  var packageVersion = '^1.0.0';
  if (argsDep == null) {
    return null; // not a packagename
  }
  if (argsDep.reference is pub.HostedReference) {
    packageVersion =
        (argsDep.reference as pub.HostedReference).versionConstraint.toString();
  }
  return packageVersion;
}
