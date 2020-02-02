#! /usr/bin/env dshell
import 'dart:convert';
import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/waitForEx.dart';

void main() {
  print('confirmed: ${confirm(prompt: "Do you agree?")}');

  print("user: ${ask(prompt: 'username:', toLower: true)}");

  print("password: ${ask(prompt: 'password:', hidden: true)}");
}

String readHidden() {
  var line = <int>[];

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
