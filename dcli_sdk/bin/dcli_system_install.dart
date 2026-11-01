#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_sdk/src/commands/system_install.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 4 ||
      !['bundle', 'single'].contains(arguments[1]) ||
      !['packed', 'unpacked'].contains(arguments[2]) ||
      !['overwrite', 'keep'].contains(arguments[3])) {
    stderr.writeln('Invalid system installation arguments.');
    exitCode = 2;
    return;
  }

  Shell.current.releasePrivileges();
  await installForAllUsers(
    CompiledExecutable(
      arguments[0],
      hasBundle: arguments[1] == 'bundle',
      isPacked: arguments[2] == 'packed',
    ),
    overwrite: arguments[3] == 'overwrite',
  );
}
