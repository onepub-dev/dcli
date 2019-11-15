import 'dart:io';

import 'package:yaml/yaml.dart';

class Yaml {
  String filename;
  YamlDocument document;

  Yaml(this.filename);

  void load() async {
    String contents = await File(filename).readAsString();
    document = loadYamlDocument(contents);
  }

  /// reads the project name from the yaml file
  ///
  String getValue(String key) {
    return document.contents.value[key] as String;
  }
}
