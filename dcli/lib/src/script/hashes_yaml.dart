/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';
import 'package:path/path.dart' as p;

import 'my_yaml.dart';

/// not currently used.
/// idea was to keep a hash of files so we can tell if they have changed.
class HashesYaml {
  ///
  HashesYaml(String scriptCachePath) {
    final cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    _hashes = MyYaml.fromFile(p.join(scriptCachePath, _fileName));
  }

  final String _fileName = 'hashes.yaml';

  /// ignore: unused_field
  late final MyYaml _hashes;

  ///
  static void create(String projectRootPath) {}
}
