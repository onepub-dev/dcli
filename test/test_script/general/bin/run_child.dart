#! /usr/bin/env dcli
import 'package:dcli/dcli.dart';

///
/// This script will '.run' a child script passed as the first and only argument.
void main(List<String> args) {
  args[0].run;
}
