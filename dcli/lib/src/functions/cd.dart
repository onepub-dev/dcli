/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:path/path.dart';

/// Change Directories to the relative or absolute path.
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
/// @Throwing(ArgumentError)
/// @Throwing(CDException)
@Deprecated('Use join')
// TODO(bsutton): to be removed in 8.x
void cd(String path) => CD().cd(path);

/// Class that implements the [cd] function.
@Deprecated('Use join')
class CD extends DCliFunction {
  /// implements the [cd] (change dir) function.
  /// Throws [CDException] if the path does not exist.
  /// @Throwing(ArgumentError)
  /// @Throwing(CDException, reason: 'if the path does not exist.')
  void cd(String path) {
    verbose(() => 'cd $path -> ${canonicalize(path)}');

    if (!exists(path)) {
      throw CDException('The path ${canonicalize(path)} does not exists.');
    }
    Directory.current = join(Directory.current.path, path);
  }
}

// to be removed in 8.x
// ignore: deprecated_member_use_from_same_package
/// Throw when the [cd] function encounters an error.
class CDException extends DCliFunctionException {
  // to be removed in 8.x
  // ignore: deprecated_member_use_from_same_package
  /// Throw when the [cd] function encounters an error.
  CDException(super.message);
}
