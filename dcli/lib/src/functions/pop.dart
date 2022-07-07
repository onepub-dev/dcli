/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

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
///  * [core.pwd]
///  * [cd]
///
@Deprecated('Use join')
void pop() => _Pop().pop();

@Deprecated('Use join')
class _Pop extends core.DCliFunction {
  ///
  /// Change the working directory back
  /// to its location before push was called.
  ///
  /// Note: change the directory changes the directory
  /// for all isolates.
  void pop() {
    if (Settings().isStackEmpty) {
      throw PopException(
        'Pop failed. You are already at the top of the stack. '
        'You need to be more pushy.',
      );
    }
    final path = InternalSettings().pop().path;

    verbose(() => 'pop:  new -> ${core.truepath(path)}');

    try {
      Directory.current = path;
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw PopException(
        'An error occured popping to ${core.truepath(path)}. Error $e',
      );
    }
  }
}

// ignore: deprecated_member_use_from_same_package
/// Thrown when the [pop] function encouters an error.
class PopException extends core.DCliFunctionException {
  // ignore: deprecated_member_use_from_same_package
  /// Thrown when the [pop] function encouters an error.
  PopException(String reason) : super(reason);
}
