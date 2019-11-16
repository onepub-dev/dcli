import 'package:test/test.dart';
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  push(TEST_ROOT);
  try {
    group("RunCommand", () {
      test("Run", () {
        var testFile = "test.text";

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        expect(exists(testFile), equals(true));
      });
    });
  } finally {
    pop();
  }
}
