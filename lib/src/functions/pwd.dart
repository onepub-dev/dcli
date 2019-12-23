import 'dart:io';

import 'dshell_function.dart';

///
/// Returns the current working directory.
///
/// ```dart
/// print(pwd);
/// ```
///
/// See [cd]
///     [push]
///     [pop]
///
String get pwd => PWD().pwd;

class PWD extends DShellFunction {
  String get pwd {
    return Directory.current.path;
  }
}
