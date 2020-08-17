#! /usr/bin/env dshell

import 'dart:io';
import 'package:dshell/dshell.dart';

void main() {
  print('child: has terminal: ${stdin.hasTerminal}');
  ask('password', hidden: true);
}
