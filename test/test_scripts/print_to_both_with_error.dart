#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  print('Hello World');
  printerr('Hello World - Error');
  exit(25);
}
