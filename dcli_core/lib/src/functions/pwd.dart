import 'dart:io';

import 'dcli_function.dart';

///
/// Returns the current working directory.
///
/// ```dart
/// print(pwd);
/// ```
///
/// See join
///
String get pwd => _PWD().pwd;

class _PWD extends DCliFunction {
  String get pwd => Directory.current.path;
}
