import 'dart:io';

import 'package:dshell/util/waitFor.dart';
import 'package:yaml/yaml.dart';

class Yaml {
  String filename;
  YamlDocument document;

  Yaml(this.filename);

  Future<void> load() async {
    if (document == null) {
      String contents = await File(filename).readAsString();
      document = loadYamlDocument(contents);
    }
  }

  /// reads the project name from the yaml file
  ///
  String getValue(String key) {
    waitFor(load());
    return document.contents.value[key] as String;
  }
}
