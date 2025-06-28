/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../../dcli.dart';

/// Base class used by all [PackedResource]s.
// ignore: one_member_abstracts
abstract class PackedResource {
  /// Create a [PackedResource] with
  /// the given b64encoded content.
  const PackedResource();

  /// The base64 encoded contents of the packed file.
  String get content;

  /// The checksum of the original file.
  /// You can use this value to see if packed file
  /// is different to a local file without having to unpack
  /// it.
  /// ```dart
  /// calculateHash('/path/to/local/file') == checksum
  /// ```
  String get checksum;

  /// The path to the original file relative to the
  /// packages resource directory.
  String get originalPath;

  /// Unpacks a resource saving it
  /// to the file at [pathTo].
  void unpack(String pathTo) {
    if (exists(pathTo) && !isFile(pathTo)) {
      throw ResourceException('The unpack target $pathTo must be a file');
    }
    final normalized = normalize(pathTo);
    if (!exists(dirname(normalized))) {
      createDir(dirname(normalized), recursive: true);
    }

    // ignore: discarded_futures
    final file = File(normalized).openSync(mode: FileMode.write);

    try {
      for (final line in content.split('\n')) {
        if (line.trim().isNotEmpty) {
          // ignore: discarded_futures
          file.writeFromSync(base64.decode(line));
        }
      }
    } finally {
      file
        ..flushSync()
        ..closeSync();
    }
  }
}
