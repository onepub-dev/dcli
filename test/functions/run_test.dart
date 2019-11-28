import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

void main() {
  Settings().debug_on = true;
  t.group("RunCommand", () {
    t.test("Run", () {
      var testFile = "test.text";

      if (exists(testFile)) {
        delete(testFile);
      }

      'touch test.text'.run;
      t.expect(exists(testFile), t.equals(true));
    });
  });
}
