#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  print('Hello World - StdOut');
  printerr('Hello World - StdErr');
  exit(25);
}
