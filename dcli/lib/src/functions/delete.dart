/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart';

import '../../dcli.dart' as dcli;

export 'package:dcli_core/dcli_core.dart' show DeleteException;

///
/// Deletes the file at [path].
///
/// If the file does not exists a DeleteException is thrown.
///
/// ```dart
/// delete("/tmp/test.fred", ask: true);
/// ```
///
/// If [ask] is true then the user is prompted to confirm the file deletion.
/// The default value for [ask] is false.
///
/// If the [path] is a directory a DeleteException is thrown.
void delete(String path, {bool ask = false}) =>
    _Delete().delete(path, ask: ask);

class _Delete extends DCliFunction {
  void delete(String path, {required bool ask}) {
    var remove = true;
    if (ask) {
      remove = false;
      final response = dcli
          .ask("delete: Delete the regular file '${dcli.truepath(path)}'? y/N");
      final yes = response;
      if (yes == 'y') {
        remove = true;
      }
    }

    if (remove == true) {
      dcli.waitForEx(core.delete(path));
    }
  }
}

/// Thrown when the [delete] function encounters an error
