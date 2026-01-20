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
  final _fileName = 'hashes.yaml';

  // may use this in the future.
  // ignore: unused_field
  late final MyYaml _hashes;

  ///
  /// @Throwing(ArgumentError)
  HashesYaml(String scriptCachePath) {
    final cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    _hashes = MyYaml.fromFile(p.join(scriptCachePath, _fileName));
  }

  ///
  static void create(String projectRootPath) {}
}
