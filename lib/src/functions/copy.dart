import 'dart:io';

import 'package:path/path.dart';

import 'function.dart';
import '../settings.dart';

import 'is.dart';

///
/// Copies the file [from] to the path [to].
///
/// ```dart
/// copy("/tmp/fred.text", "/tmp/fred2.text", overwrite=true);
/// ```
///
/// [to] may be a directory in which case the [from] filename is
/// used to construct the [to] files full path.
///
/// The [to] file must not exists unless [overwrite] is set to true.
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyException] is thrown.
void copy(String from, String to, {bool overwrite = false}) =>
    Copy().copy(from, to, overwrite: overwrite);

class Copy extends DShellFunction {
  void copy(String from, String to, {bool overwrite = false}) {
    if (isDirectory(to)) {
      to = join(to, basename(from));
    }

    if (overwrite == false && exists(to)) {
      throw CopyException('The target file ${absolute(to)} already exists');
    }

    try {
      File(from).copySync(to);
    } catch (e) {
      throw CopyException(
          'An error occured copying ${absolute(from)} to ${absolute(to)}. Error: $e');
    }

    Settings().verbose('copy ${absolute(from)} -> ${absolute(to)}');
  }
}

class CopyException extends FunctionException {
  CopyException(String reason) : super(reason);
}
