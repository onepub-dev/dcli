#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  print('child: has terminal: ${stdin.hasTerminal}');
  print('confirmed: ${confirm("Do you agree?")}');

  print("user: ${ask('username:', toLower: true)}");

  print("password: ${ask('password:', hidden: true)}");
}

// ignore: unreachable_from_main
String readHidden() {
  final line = <int>[];

  print('read hidden');

  try {
    stdin.echoMode = false;
    stdin.lineMode = false;
    int char;
    do {
      char = stdin.readByteSync();
      if (char != 10) {
        stdout.write('*');
        line.add(char);
      }
    } while (char != 10);
  } finally {
    stdin.echoMode = true;
    stdin.lineMode = true;
  }
  return Encoding.getByName('utf-8')!.decode(line);
}
