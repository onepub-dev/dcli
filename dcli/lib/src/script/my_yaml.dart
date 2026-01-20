/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:yaml/yaml.dart' as y;

/// wrapper for the YamlDocument
/// designed to make it easier to read yaml files.
class MyYaml {
  late y.YamlDocument _document;

  /// read yaml from string
  /// @Throwing(StateError)
  /// @Throwing(y.YamlException)
  MyYaml.fromString(String content) {
    _document = _load(content);
  }

  /// reads yaml from file.
  /// @Throwing(StateError)
  /// @Throwing(y.YamlException)
  MyYaml.fromFile(String path) {
    final contents = File(path).readAsStringSync();
    _document = _load(contents);
  }

  /// @Throwing(StateError)
  /// @Throwing(y.YamlException)
  y.YamlDocument _load(String content) => y.loadYamlDocument(content);

  /// returns the raw content of the yaml file.
  String get content => _document.toString();

  /// reads the project name from the yaml file
  ///
  String? getValue(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return (_document.contents.value as Map)[key] as String?;
    }
  }

  /// returns the list of elements attached to [key].
  y.YamlList? getList(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return (_document.contents.value as Map)[key] as y.YamlList?;
    }
  }

  /// returns the map of elements attached to [key].
  y.YamlMap? getMap(String key) {
    if (_document.contents.value == null) {
      return null;
    } else {
      return (_document.contents.value as Map)[key] as y.YamlMap?;
    }
  }
}
