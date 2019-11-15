import 'dart:io';

import 'b_command.dart';
import 'package:yaml/yaml.dart';

import 'a_command2.dart' as a;

class YamlMe {
  String filename;
  YamlDocument document;

  YamlMe(this.filename);

  void load() async {
    String contents = await File("pubspec.yaml").readAsString();
    document = loadYamlDocument(contents);
  }

  /// reads the project name from the yaml file
  ///
  String getValue(String key) {
    return document.contents.value[key] as String;
  }
}

void fred() {
  BCommand();
  a.ACommand();
}
