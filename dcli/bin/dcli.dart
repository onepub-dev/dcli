#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/entry_point.dart';

void main(List<String> arguments) {
  DCli().run(arguments);
}

class DCli {
  void run(List<String> arguments) {
    final exitCode = EntryPoint().process(arguments);

    dcliExit(exitCode);
  }
}
