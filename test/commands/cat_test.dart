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

    t.test("Cat good ", () {
      List<String> lines = List();

      cat(testFile, stdout: (line) => lines.add(line));
      t.expect(lines.length, t.equals(10));
    });

    t.test("cat non-existing ", () {
      t.expect(
          () => cat("bad file.text"), t.throwsA(t.TypeMatcher<CatException>()));
    });
  });
}
