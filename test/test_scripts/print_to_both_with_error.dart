#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';

void main() {
  print('Hello World');
  printerr('Hello World - Error');
  exit(25);
}
