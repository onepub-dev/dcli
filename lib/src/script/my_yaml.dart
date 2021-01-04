import 'dart:cli';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:yaml/yaml.dart' as y;
import '../pubspec/dependency.dart';

/// wrapper for the YamlDocument
/// designed to make it easier to read yaml files.
class MyYaml {
  late y.YamlDocument _document;

  /// read yaml from string
  MyYaml.fromString(String content) {
    _document = _load(content);
  }

  /// returns the raw content of the yaml file.
  String get content => _document.toString();

  /// reads yaml from file.
  MyYaml.fromFile(String path) {
    final contents = waitFor<String>(File(path).readAsString());
    _document = _load(contents);
  }

  y.YamlDocument _load(String content) {
    return y.loadYamlDocument(content);
  }

  /// reads the project name from the yaml file
  ///
  String? getValue(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return _document.contents.value[key] as String?;
    }
  }

  /// returns the list of elements attached to [key].
  y.YamlList? getList(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return _document.contents.value[key] as y.YamlList?;
    }
  }

  /// returns the map of elements attached to [key].
  y.YamlMap? getMap(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return _document.contents.value[key] as y.YamlMap?;
    }
  }

  /// addes a list to the yaml.
  void setList(String key, List<Dependency> list) {
    _document.contents.value[key] = list;
  }
}
