@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

import '../../util/test_file_system.dart';

void main() {
  final scriptPath = truepath(TestFileSystem().tmpScriptPath, 'create_test');

  if (!exists(scriptPath)) {
    createDir(scriptPath, recursive: true);
  }
  final pathToScript = truepath(scriptPath, 'hello_world.dart');

  group('Create Project', () {
    test('Create hello world', () {
      TestFileSystem().withinZone((fs) {
        if (exists(pathToScript)) {
          delete(pathToScript);
        }
        DartProject.fromPath(scriptPath)
          ..createScript(pathToScript, templateName: 'hello_world.dart')
          ..warmup();

        checkProjectStructure(fs, pathToScript);
      });
    });

    test('Run hello world', () {
      TestFileSystem().withinZone((fs) {
        DartScript.fromFile(pathToScript).run();
      });
    });

    test('With Lib', () {});
  });
}

void checkProjectStructure(TestFileSystem fs, String scriptName) {
  expect(exists(fs.runtimePath(scriptName)), equals(true));

  final pubspecPath = p.join(fs.runtimePath(scriptName), 'pubspec.yaml');
  expect(exists(pubspecPath), equals(true));

  // There should be:
  // script
  // pubspec.lock
  // pubspec.yaml
  // .packages
  // .dart_tools
  // analysis_options.yaml

  final files = <String>[];
  find(
    '*.*',
    workingDirectory: fs.runtimePath(scriptName),
    types: [Find.file],
    includeHidden: true,
  ).forEach(
    (line) => files.add(
      p.relative(line, from: fs.runtimePath(scriptName)),
    ),
  );

  // find('.*', recursive: false, root: fs.runtimePath(scriptName), types: [
  //   Find.file,
  // ]).forEach((line) => files.add(p.basename(line)));

  expect(
      files,
      unorderedEquals(<String>[
        'hello_world.dart',
        'pubspec.yaml',
        'pubspec.lock',
        'analysis_options.yaml',
        join('.dart_tool', 'package_config.json'),
        // ignore: lines_longer_than_80_chars
        '.packages' // when dart 2.10 is released this will no longer be created.
      ]));

  final directories = <String>[];

  find('*',
          recursive: false,
          workingDirectory: fs.runtimePath(scriptName),
          types: [Find.directory],
          includeHidden: true)
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['.dart_tool']));
}
