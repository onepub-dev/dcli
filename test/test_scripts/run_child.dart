#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';

///
/// This script will '.run' a child script passed as the first and only argument.
void main(List<String> args) {
  args[0].run;
}
