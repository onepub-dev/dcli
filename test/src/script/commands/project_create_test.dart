@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

import '../../util/test_file_system.dart';

void main() {
  var scriptPath = truepath(TestFileSystem().testScriptPath, 'create_test');

  if (!exists(scriptPath)) {
    createDir(scriptPath, recursive: true);
  }
  var script = truepath(scriptPath, 'hello_world.dart');

  group('Create Project', () {
    test('Create hello world', () {
      TestFileSystem().withinZone((fs) {
        if (exists(script)) {
          delete(script);
        }
        EntryPoint().process(['create', '--foreground', script]);

        checkProjectStructure(fs, script);
      });
    });

    test('Clean hello world', () {
      TestFileSystem().withinZone((fs) {
        if (exists(script)) {
          delete(script);
        }

        EntryPoint().process(['create', '--foreground', script]);

        EntryPoint().process(['clean', script]);

        checkProjectStructure(fs, script);
      });
    });

    test('Run hello world', () {
      TestFileSystem().withinZone((fs) {
        EntryPoint().process([script]);
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
    types: [FileSystemEntityType.file],
    includeHidden: true,
  ).forEach(
    (line) => files.add(
      p.relative(line, from: fs.runtimePath(scriptName)),
    ),
  );

  // find('.*', recursive: false, root: fs.runtimePath(scriptName), types: [
  //   FileSystemEntityType.file,
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
          types: [FileSystemEntityType.directory],
          includeHidden: true)
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['lib', '.dart_tool']));
}
