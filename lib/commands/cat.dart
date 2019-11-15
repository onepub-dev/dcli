import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'command.dart';
import 'is.dart';
import 'settings.dart';
import '../util/log.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// If the file does not exists then a CatException is thrown.
///
void cat(String path) => Cat().cat(path);

class Cat extends Command {
  void cat(String path) {
    File sourceFile = File(path);

    if (Settings().debug_on) {
      Log.d("cat:  ${absolute(path)}");
    }

    if (!exists(path)) {
      throw CatException("The file at ${absolute(path)} does not exists");
    }
    waitFor<void>(sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) => print(line)));
  }
}

class CatException extends CommandException {
  CatException(String reason) : super(reason);
}
