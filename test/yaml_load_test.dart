import 'dart:io';

import 'package:yaml/yaml.dart';

void main() async {
  await getProjectName();
}

/// reads the project name from the yaml file
///
Future<String> getProjectName() async {
  String contents = await File("pubspec.yaml").readAsString();

  YamlDocument pubSpec = loadYamlDocument(contents);
  print(pubSpec.contents.value["name"]);
  return pubSpec.contents.value["name"] as String;
}
