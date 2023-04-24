/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
String touch(String path, {bool create = false}) =>
    _Touch().touch(path, create: create);

class _Touch extends DCliFunction {
  String touch(String path, {bool create = false}) {
    final absolutePath = truepath(path);

    verbose(() => 'touch: $absolutePath create: $create');

    if (!exists(p.dirname(absolutePath))) {
      throw TouchException(
        'The directory tree above $absolutePath does not exist. '
        'Create the tree and try again.',
      );
    }
    if (create == false && !exists(absolutePath)) {
      throw TouchException(
        'The file $absolutePath does not exist. '
        'Did you mean to use touch(path, create: true) ?',
      );
    }

    try {
      final file = File(absolutePath);

      if (file.existsSync()) {
        final now = DateTime.now();
        file.setLastAccessedSync(now);
        file.setLastModifiedSync(now);
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
}

/// thrown when the [touch] function encounters an exception
class TouchException extends DCliFunctionException {
  /// thrown when the [touch] function encounters an exception
  TouchException(super.reason);
}
