#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';
import 'package:dcli/dcli.dart';

void main() {
  print('child: has terminal: ${stdin.hasTerminal}');
  ask('password', hidden: true);
}
