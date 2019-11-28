#! /usr/bin/env dshell
/*
@pubspec.yaml
name: hello_world.dart
dependencies:
  dshell: ^1.0.0
  money2: ^1.0.0
*/

import 'dart:io';
import 'package:dshell/dshell.dart';
import 'package:path/path.dart' as p;
import 'package:money2/money2.dart';

void main() {
  print("Hello World.");
}
