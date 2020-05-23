import 'dart:io';

import 'dshell_function.dart';

///
/// Returns the current working directory.
///
/// ```dart
/// print(pwd);
/// ```
///
/// See [join]
///
String get pwd => _PWD().pwd;

class _PWD extends DShellFunction {
  String get pwd {
    return Directory.current.path;
  }
}
