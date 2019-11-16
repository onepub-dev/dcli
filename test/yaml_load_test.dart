import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'test_settings.dart';

void main() async {
  Settings().debug_on = true;
  push(TEST_ROOT);

  try {
    test("Project Name", () async {
      await getProjectName();
    });
  } finally {
    pop();
  }
}

/// reads the project name from the yaml file
///
Future<String> getProjectName() async {
  String contents = await File("pubspec.yaml").readAsString();

  YamlDocument pubSpec = loadYamlDocument(contents);
  print(pubSpec.contents.value["name"]);
  return pubSpec.contents.value["name"] as String;
}
