import 'dart:io';

import 'command.dart';

///
/// Returns the current working directory.
///
/// See [cd]
///     [push]
///     [pop]
///
String get pwd => PWD().pwd;

class PWD extends Command {
  String get pwd {
    return Directory.current.path;
  }
}
