#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/wait_for_ex.dart';

void main() {
  print('child: has terminal: ${stdin.hasTerminal}');
  print('confirmed: ${confirm("Do you agree?")}');

  print("user: ${ask('username:', toLower: true)}");

  print("password: ${ask('password:', hidden: true)}");
}

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
        waitForEx<void>(stdout.flush());
        line.add(char);
      }
    } while (char != 10);
  } finally {
    stdin.echoMode = true;
    stdin.lineMode = true;
  }

  return Encoding.getByName('utf-8').decode(line);
}
