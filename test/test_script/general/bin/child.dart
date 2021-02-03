#! /usr/bin/env dcli
import 'dart:io';
import 'package:dcli/dcli.dart';

void main() {
  print('child: has terminal: ${stdin.hasTerminal}');
  ask('password', hidden: true);
}
