/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import '../settings.dart';
import 'cd.dart';
import 'pop.dart';

///
/// Pushes the given [path] onto the stack
/// and changes the current directory to [path]
///
/// ```dart
/// push('/tmp');
/// ```
///
/// If [path] is not a valid directory a
/// [PushException] is thrown.
///
/// Note: change the directory changes the directory
/// for all isolates.
///
/// See:
///  * [cd]
///  * [pop]
///  * [pwd]
/// @Throwing(ArgumentError)
/// @Throwing(PushException)
@Deprecated('Use join')
// TODO(bsutton): to be removed in 8.x
void push(String path) => _Push().push(path);

@Deprecated('Use join')
class _Push extends core.DCliFunction {
        /// Push the pwd onto the stack and change the
    /// current directory to [path].
    /// Throws [PushException].
    /// @Throwing(ArgumentError)
    /// @Throwing(PushException)
  void push(String path) {
    verbose(() => 'push: path: $path new -> ${core.truepath(path)}');

    if (!exists(path)) {
      throw PushException('The path ${core.truepath(path)} does not exist.');
    }

    if (!isDirectory(path)) {
      throw PushException(
          'The path ${core.truepath(path)} is not a directory.');
    }

    InternalSettings().push(Directory.current);

    try {
      Directory.current = path;
    }
    catch (e) {
      throw PushException(
        'An error occured pushing to ${core.truepath(path)}. Error $e',
      );
    }
  }
}

// to be removed in 8.x
// ignore: deprecated_member_use_from_same_package
/// Thrown when the [push] function encouters an error.
class PushException extends core.DCliFunctionException {
  // to be removed in 8.x
  // ignore: deprecated_member_use_from_same_package
  /// Thrown when the [push] function encouters an error.
  PushException(super.message);
}
