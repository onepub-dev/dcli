@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/script/commands/commands.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/script/project_cache.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  group('Create Project', () {
    test('Create hello world', () {
      TestZone().run(() {
        var paths = TestPaths();
        setup(paths);
        EntryPoint().process(['create', script]);

        checkProjectStructure(paths, script);
      });
    });

    test('Clean hello world', () {
      TestZone().run(() {
        var paths = TestPaths();
        setup(paths);
        EntryPoint().process(['clean', script]);

        checkProjectStructure(paths, script);
      });
    });

    test('Run hello world', () {
      TestZone().run(() {
        EntryPoint().process([script]);
      });
    });

    test('With Lib', () {});
  });
}

void setup(TestPaths paths) {
  CommandLineRunner.init(Commands.applicationCommands);
  ProjectCache().cleanAll();
}

void checkProjectStructure(TestPaths paths, String scriptName) {
  expect(exists(paths.projectPath(scriptName)), equals(true));

  var pubspecPath = p.join(paths.projectPath(scriptName), 'pubspec.yaml');
  expect(exists(pubspecPath), equals(true));

  var libPath = p.join(paths.projectPath(scriptName), 'lib');
  expect(exists(libPath), equals(true));

  // There should be three files/directories in the project.
  // script link
  // lib or lib link
  // pubspec.lock
  // pubspec.yaml
  // .packages

  var files = <String>[];
  find('*.*', recursive: false, root: paths.projectPath(scriptName), types: [
    FileSystemEntityType.file,
  ]).forEach((line) => files.add(p.basename(line)));
  expect(
      files,
      unorderedEquals((<String>[
        'hello_world.dart',
        'pubspec.yaml',
        'pubspec.lock',
        '.packages'
      ])));

  var directories = <String>[];

  find('*.*',
          recursive: false,
          root: paths.projectPath(scriptName),
          types: [FileSystemEntityType.directory])
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['lib', '.dart_tool']));
}
