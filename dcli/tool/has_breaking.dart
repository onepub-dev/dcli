#! /usr/bin/env dart

import 'package:dcli/dcli.dart';

void main() {
  'dart-apitool diff --old pub://dcli --new .'.run;
  'dart-apitool diff --old pub://dcli_core --new ../dcli_core'.run;
  'dart-apitool diff --old pub://dcli_terminal --new ../dcli_terminal'.run;
  'dart-apitool diff --old pub://dcli_input --new ../dcli_input'.run;
  'dart-apitool diff --old pub://dcli_common --new ../dcli_common'.run;
}
