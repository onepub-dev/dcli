import 'package:test/test.dart';
import "package:dshell/dshell.dart";

void main() {
  group("RunCommand", () {
    List<String> lines = List();
    test("Run", () {
      var testFile = "test.text";

      if (exists(testFile)) {
        delete(testFile);
      }

      'touch test.text'.run;
      expect(exists(testFile), equals(true));
    });
  });
}
