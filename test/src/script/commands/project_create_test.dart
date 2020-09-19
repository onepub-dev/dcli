@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

import '../../util/test_file_system.dart';

void main() {
  var scriptPath = truepath(TestFileSystem().tmpScriptPath, 'create_test');

  if (!exists(scriptPath)) {
    createDir(scriptPath, recursive: true);
  }
  var pathToScript = truepath(scriptPath, 'hello_world.dart');

  group('Create Project', () {
    test('Create hello world', () {
      TestFileSystem().withinZone((fs) {
        if (exists(pathToScript)) {
          delete(pathToScript);
        }
        var project = DartProject.fromPath(scriptPath);
        project.createScript(pathToScript, templateName: 'hello_world.dart');

        checkProjectStructure(fs, pathToScript);
      });
    });

    test('warmup hello world', () {
      TestFileSystem().withinZone((fs) {
        if (exists(pathToScript)) {
          delete(pathToScript);
        }

        var project = DartProject.fromPath(dirname(pathToScript));
        project.createScript(basename(pathToScript));
        project.warmup();

        checkProjectStructure(fs, pathToScript);
      });
    });

    test('Run hello world', () {
      TestFileSystem().withinZone((fs) {
        Script.fromFile(pathToScript).run([]);
      });
    });

    test('With Lib', () {});
  });
}

void checkProjectStructure(TestFileSystem fs, String scriptName) {
  expect(exists(fs.runtimePath(scriptName)), equals(true));

  var pubspecPath = p.join(fs.runtimePath(scriptName), 'pubspec.yaml');
  expect(exists(pubspecPath), equals(true));

  var libPath = p.join(fs.runtimePath(scriptName), 'lib');
  expect(exists(libPath), equals(true));

  // There should be three files/directories in the project.
  // script link
  // lib or lib link
  // pubspec.lock
  // pubspec.yaml
  // .packages

  var files = <String>[];
  find(
    '*.*',
    recursive: true,
    root: fs.runtimePath(scriptName),
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
      unorderedEquals((<String>[
        'hello_world.dart',
        'pubspec.yaml',
        'pubspec.lock',
        join('.dart_tool', 'package_config.json'),
        '.build.complete',
        '.using.virtual.pubspec',
        '.packages' // when dart 2.10 is released this will no longer be created.
      ])));

  var directories = <String>[];

  find('*',
          recursive: false,
          root: fs.runtimePath(scriptName),
          types: [Find.directory],
          includeHidden: true)
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['lib', '.dart_tool']));
}
