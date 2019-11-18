import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  String linesFile = join(TEST_ROOT, TEST_LINES_FILE);

  if (!exists(TEST_ROOT)) {
    makeDir(TEST_ROOT);
  }

  if (!exists(linesFile)) {
    FileSync file = FileSync(linesFile);
    for (int i = 0; i < 10; i++) {
      file.append("Line $i");
    }
  }
  t.group("StringAsProcess", () {
    t.test("Run", () {
      var testFile = "test.text";

      if (exists(testFile)) {
        delete(testFile);
      }

      'touch test.text'.run;
      t.expect(exists(testFile), t.equals(true));
    });

    t.test("forEach", () {
      List<String> lines = List();

      print("pwd" + pwd);

      assert(exists(linesFile));

      'tail -n 5 $linesFile'.forEach((line) => lines.add(line));

      t.expect(lines.length, t.equals(5));
    });
/*
    t.test("Pipe operator", () {
      'head -n 5 ../data/lines.txt' | 'tail -n 1'.run;
      t.expect(lines.length, t.equals(1));
    });
    */

    t.test("Lines", () {
      List<String> lines = 'head -n 5 /var/log/syslog'.lines;
      t.expect(lines.length, t.equals(5));
    });
  });
}
