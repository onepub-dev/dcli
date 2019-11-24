import 'dart:cli';
import 'dart:io';

import 'package:yaml/yaml.dart';

class Yaml {
  String file;
  YamlDocument document;

  Yaml(this.file);

  void load() {
    String contents = waitFor<String>(File(file).readAsString());
    document = loadYamlDocument(contents);
  }

  /// reads the project name from the yaml file
  ///
  String getValue(String key) {
    return document.contents.value[key] as String;
  }
}
