import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';
import '../util.dart';

void main() {
  Settings().debug_on = true;

  String testFile = join(TEST_ROOT, "lines.txt");

  t.group("Cat", () {
    print("PWD $pwd");
    createLineFile(testFile, 10);

    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    t.test("Cat good ", () {
      List<String> lines = List();

      cat(testFile);
      t.expect(lines.length, t.equals(10));
    }, skip: true);

    t.test("cat non-existing ", () {
      t.expect(
          () => cat("bad file.text"), t.throwsA(t.TypeMatcher<CatException>()));
    });
  });
}
