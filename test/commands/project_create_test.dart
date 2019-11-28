@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/functions/find.dart';
import 'package:dshell/functions/is.dart';
import 'package:dshell/script/command_line_runner.dart';
import 'package:dshell/script/commands/commands.dart';
import 'package:dshell/script/entry_point.dart';
import 'package:dshell/script/flags.dart';
import 'package:dshell/script/project_cache.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

String script = "test/test_scripts/hello_world.dart";

String cwd = Directory.current.path;
String cachePath = ProjectCache().path;

String scriptDir = p.join(cwd, script);
String scriptPath = p.dirname(scriptDir);
String scriptName = p.basenameWithoutExtension(scriptDir);
String projectPath =
    p.join(cachePath, scriptPath.substring(1), scriptName + ".project");

void main() {
  group("Create Project", () {
    setup();

    test('Create hello world', () {
      EntryPoint().process(["create", script]);

      checkProjectStructure();
    });

    test('Clean hello world', () {
      EntryPoint().process(["clean", script]);

      checkProjectStructure();
    });

    test('Run hello world', () {
      EntryPoint().process([script]);
    });

    test('With Lib', () {});
  });
}

void setup() {
  CommandLineRunner.init(Flags.applicationFlags, Commands.applicationCommands);
  ProjectCache().cleanAll();
}

void checkProjectStructure() {
  expect(exists(projectPath), equals(true));

  String pubspecPath = p.join(projectPath, "pubspec.yaml");
  expect(exists(pubspecPath), equals(true));

  String libPath = p.join(projectPath, "lib");
  expect(exists(libPath), equals(true));

  // There should be three files/directories in the project.
  // script link
  // lib or lib link
  // pubspec.lock
  // pubspec.yaml
  // .packages

  List<String> files;
  find('*.*', recursive: false, root: projectPath, types: [
    FileSystemEntityType.file,
  ]).forEach((line) => files.add(p.basename(line)));
  expect(
      files,
      unorderedEquals((<String>[
        "hello_world.dart",
        "pubspec.yaml",
        "pubspec.lock",
        ".packages"
      ])));

  List<String> directories = List();

  find('*.*',
          recursive: false,
          root: projectPath,
          types: [FileSystemEntityType.directory])
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>["lib", ".dart_tool"]));
}
