#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/src/script/entry_point.dart';

void main(List<String> arguments) async {
  await DCliInstall().run(arguments);
}

class DCliInstall {
  Future<void> run(List<String> arguments) async {
    final mutableArgs = <String>[...arguments];

    if (!mutableArgs.contains('doctor')) {
      // We add the 'install' so we do the install
      // by default, unless they passed `doctor`.
      // We do an add so they can still pass global
      // switches such as -v
      mutableArgs.add('install');
    }
    await EntryPoint().process(mutableArgs);
  }
}
