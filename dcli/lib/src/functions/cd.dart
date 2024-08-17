/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:path/path.dart';

/// Change Directories to the relative or absolute path.
///
/// If [path] does not exists an exception is thrown
///
/// ```dart
/// cd("/tmp");
/// ```
///
/// NOTE: changing the directory changes the directory
/// for all isolates.
///
/// Using push/pop/cd is considered bad form.
///
/// Instead use absolute or relative paths.
///
/// See:
///  * [join] in prefrence to cd/push/pop
@Deprecated('Use join')
void cd(String path) => CD().cd(path);

/// Class that implements the [cd] function.
@Deprecated('Use join')
class CD extends DCliFunction {
  /// implements the [cd] (change dir) function.
  void cd(String path) {
    verbose(() => 'cd $path -> ${canonicalize(path)}');

    if (!exists(path)) {
      throw CDException('The path ${canonicalize(path)} does not exists.');
    }
    Directory.current = join(Directory.current.path, path);
  }
}

// ignore: deprecated_member_use_from_same_package
/// Throw when the [cd] function encounters an error.
class CDException extends DCliFunctionException {
  // ignore: deprecated_member_use_from_same_package
  /// Throw when the [cd] function encounters an error.
  CDException(super.message);
}
