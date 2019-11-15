import 'dart:io';

import 'package:dshell/commands/command.dart';

import '../util/log.dart';
import 'package:path/path.dart' as p;

import 'settings.dart';

///
/// Push and Pop work together to track a series
/// of current directory changes.
/// These operators are useful when peformaning a series
/// of operations on different directories and you need
/// a simple method to get back to an earlier directory.
///
/// ```dart
///  print(pwd);
///    > /home
///
///  push("tools");
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
/// See [push]
///     [pwd]
///     [cd]
///
void pop() => Pop().pop();

class Pop extends Command {
  ///
  /// Change the working directory back
  /// to its location before [push] was called.
  ///
  /// Note: change the directory changes the directory
  /// for all isolates.
  void pop() {
    if (Settings().isStackEmpty) {
      throw PopException(
          "Pop failed. You are already at the top of the stack. You need to be more pushy.");
    }
    String path = InternalSettings().pop().path;

    if (Settings().debug_on) {
      Log.d("pop:  new -> ${p.absolute(path)}");
    }

    try {
      Directory.current = path;
    } catch (e) {
      throw PopException(
          "An error occured popping to ${absolute(path)}. Error $e");
    }
  }
}

class PopException extends CommandException {
  PopException(String reason) : super(reason);
}
