import 'dart:io';

import 'package:dshell/script/entry_point.dart';
import 'package:dshell/script/project_cache.dart';
import 'package:dshell/util/file_helper.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

String script = "test_scripts/hello_world.dart";

void main() {
  group("Create Project", () {
    setup();

    test('Run hello world', () async {
      await EntryPoint().process("Hello World", "1.0.0", [script, "world"]);

      checkProjectStructure();
    });
  });
}

void setup() {
  ProjectCache().cleanAll();
}

void checkProjectStructure() {
  String cwd = Directory.current.path;
  String cachePath = ProjectCache().cachePath;

  String scriptDir = p.join(cwd, script);
  String scriptPath = p.dirname(scriptDir);
  String scriptName = p.basename(scriptDir);

  String projectPath = p.join(cachePath, scriptPath, scriptName, ".dir");
  print("Project Path: ${projectPath}");
  expect(exists(projectPath), equals(true));

  String pubspecPath = p.join(projectPath, "pubspec.yaml");
  expect(exists(pubspecPath), equals(true));

  String libPath = p.join(projectPath, "lib");
  expect(exists(libPath), equals(true));
}
