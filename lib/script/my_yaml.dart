import 'dart:cli';
import 'dart:io';

import 'package:yaml/yaml.dart' as y;

class MyYaml {
  y.YamlDocument document;

  MyYaml.fromString(String content) {
    document = _load(content);
  }

  String get content => document.toString();

  MyYaml.loadFromFile(String path) {
    String contents = waitFor<String>(File(path).readAsString());
    document = _load(contents);
  }

  y.YamlDocument _load(String content) {
    return y.loadYamlDocument(content);
  }

  /// reads the project name from the yaml file
  ///
  String getValue(String key) {
    if (document.contents.value == null) {
      return null;
    } else {
      return document.contents.value[key] as String;
    }
  }

  y.YamlList getList(String key) {
    if (document.contents.value == null) {
      return null;
    } else {
      return document.contents.value[key] as y.YamlList;
    }
  }

  y.YamlMap getMap(String key) {
    if (document.contents.value == null) {
      return null;
    } else {
      return document.contents.value[key] as y.YamlMap;
    }
  }
}
