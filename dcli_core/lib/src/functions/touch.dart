/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../dcli_core.dart';

/// Updates the last modified time stamp of a file.
///
/// ```dart
/// touch('fred.txt');
/// touch('fred.txt, create: true');
/// ```
///
///
/// If [create] is true and the file doesn't exist
/// it will be created.
///
/// If [create] is false and the file doesn't exist
/// a [TouchException] will be thrown.
///
/// [create] is false by default.
///
/// As a convenience the touch function returns the [path] variable
/// that was passed in.

String touch(String path, {bool create = false}) {
  final absolutePath = truepath(path);

  verbose(() => 'touch: $absolutePath create: $create');

  if (!exists(p.dirname(absolutePath))) {
    throw TouchException(
      'The directory tree above $absolutePath does not exist. '
      'Create the tree and try again.',
    );
  }
  if (!create && !exists(absolutePath)) {
    throw TouchException(
      'The file $absolutePath does not exist. '
      'Did you mean to use touch(path, create: true) ?',
    );
  }

  try {
    final file = File(absolutePath);

    if (file.existsSync()) {
      final now = DateTime.now();
      file
        ..setLastAccessedSync(now)
        ..setLastModifiedSync(now);
    } else {
      if (create) {
        file.createSync();
      }
    }
  } on FileSystemException catch (e) {
    throw TouchException('Unable to touch file $absolutePath: ${e.message}');
  }
  return path;
}

/// thrown when the [touch] function encounters an exception
class TouchException extends DCliFunctionException {
  /// thrown when the [touch] function encounters an exception
  TouchException(super.message);
}
