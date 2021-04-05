#! /usr/bin/env dcli

import 'package:dcli/src/script/entry_point.dart';

void main(List<String> arguments) {
  DCliInstall().run(arguments);
}

class DCliInstall {
  void run(List<String> arguments) {
    final mutableArgs = <String>[...arguments];

    if (!mutableArgs.contains('doctor')) {
      // We add the 'install' so we do the install
      // by default.
      // Unless they passed doctor.
      // We do an add so they can still pass global
      // switches such as -v
      mutableArgs.add('install');
    }
    EntryPoint().process(mutableArgs);
  }
}
