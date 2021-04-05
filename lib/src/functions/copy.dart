import 'dart:io';

import 'package:dcli/src/util/truepath.dart';
import 'package:path/path.dart';

import '../settings.dart';
import 'function.dart';

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
    _Copy().copy(from, to, overwrite: overwrite);

class _Copy extends DCliFunction {
  void copy(String from, String to, {bool overwrite = false}) {
    var finalto = to;
    if (isDirectory(finalto)) {
      finalto = join(finalto, basename(from));
    }

    Settings().verbose('copy ${truepath(from)} -> ${truepath(finalto)}');

    if (overwrite == false && exists(finalto)) {
      throw CopyException(
          'The target file ${truepath(finalto)} already exists');
    }

    try {
      File(from).copySync(finalto);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CopyException(
          'An error occured copying ${truepath(from)} to ${truepath(finalto)}. '
          'Error: $e');
    }
  }
}

/// Throw when the [copy] function encounters an error.
class CopyException extends FunctionException {
  /// Throw when the [copy] function encounters an error.
  CopyException(String reason) : super(reason);
}
