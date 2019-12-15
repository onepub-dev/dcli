import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';
import '../util.dart';
import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group("Piping", () {
    List<String> lines = List();

    t.test("Run", () {
      TestZone().run(() {
        String linesFile = join(TEST_ROOT, TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        'tail -n 100 $linesFile'.forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test("Single Pipe", () {
      TestZone().run(() {
        String linesFile = join(TEST_ROOT, TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail -n 100 $linesFile' | 'head -n 5')
            .forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test("Double Pipe", () {
      TestZone().run(() {
        String linesFile = join(TEST_ROOT, TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });
    });

    t.test("Triple Pipe", () {
      TestZone().run(() {
        String linesFile = join(TEST_ROOT, TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'head -n 3' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });
    });
  });
}
