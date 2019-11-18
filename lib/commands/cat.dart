import 'dart:convert';
import 'dart:io';

import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/runnable_process.dart';

import 'package:dshell/util/stack_trace_impl.dart';
import 'package:dshell/util/waitForEx.dart';

import 'command.dart';
import 'is.dart';
import 'settings.dart';
import '../util/log.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// If the file does not exists then a CatException is thrown.
///
void cat(String path, {LineAction stdout}) => Cat().cat(path, stdout: stdout);

class Cat extends Command {
  void cat(String path, {LineAction stdout}) {
    File sourceFile = File(path);

    if (Settings().debug_on) {
      Log.d("cat:  ${absolute(path)}");
    }

    if (!exists(path)) {
      throw CatException("The file at ${absolute(path)} does not exists");
    }
    waitForEx<void>(sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) {
      if (stdout == null) {
        print(line);
      } else {
        stdout(line);
      }
    }));
  }
}

class CatException extends CommandException {
  CatException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return CatException(message, stackTrace);
  }
}
