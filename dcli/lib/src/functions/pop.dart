/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import '../../dcli.dart';
import '../settings.dart';
import 'cd.dart';
import 'push.dart';

///
/// Push and Pop work together to track a series
/// of current directory changes.
///
/// ```dart
/// pop();
/// ```
///
/// These operators are useful when peformaning a series
/// of operations on different directories and you need
/// a simple method to get back to an earlier directory.
///
/// ```dart
///  print(pwd);
///    > /home
///
///  push('tools');
///  print(pwd);
///    > /home/tools
///
///   pop();
///   print(pwd);
///     > /home
/// ```
/// Pops the current directory off the directory stack
/// and changes directory to the directory now at the
/// top of the stack.
///
/// If you pop and there are no more directories
/// on the stack then a [PopException] is thrown.
///
/// See:
///  * [push]
///  * [pwd]
///  * [cd]
///
@Deprecated('Use join')
void pop() => _Pop().pop();

@Deprecated('Use join')
class _Pop extends DCliFunction {
  ///
  /// Change the working directory back
  /// to its location before push was called.
  ///
  /// Note: change the directory changes the directory
  /// for all isolates.
  /// Throws [PopException].
  // TODO(bsutton): to be removed in 8.x
  void pop() {
    if (Settings().isStackEmpty) {
      throw PopException(
        'Pop failed. You are already at the top of the stack. '
        'You need to be more pushy.',
      );
    }
    final path = InternalSettings().pop().path;

    verbose(() => 'pop:  new -> ${truepath(path)}');

    try {
      Directory.current = path;
    } catch (e) {
      throw PopException(
        'An error occured popping to ${truepath(path)}. Error $e',
      );
    }
  }
}

// to be removed in 8.x
// ignore: deprecated_member_use_from_same_package
/// Thrown when the [pop] function encouters an error.
class PopException extends DCliFunctionException {
  // to be removed in 8.x
  // ignore: deprecated_member_use_from_same_package
  /// Thrown when the [pop] function encouters an error.
  PopException(super.message);
}
