#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_sdk/src/script/entry_point.dart';
import 'package:dcli_sdk/src/util/exit.dart';

void main(List<String> arguments) async {
  await DCli().run(arguments);
}

class DCli {
  Future<void> run(List<String> arguments) async {
    final exitCode = await EntryPoint().process(arguments);

    dcliExit(exitCode);
  }
}
