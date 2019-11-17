import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  push(TEST_ROOT);
  try {
    t.group("Piping", () {
      List<String> lines = List();
      t.test("Single Pipe", () {
        ('tail /var/log/syslog' | 'head -n 5')
            .forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });

      t.test("Double Pipe", () {
        lines.clear();
        ('tail /var/log/syslog' | 'head -n 5' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });

      t.test("Triple Pipe", () {
        lines.clear();
        ('tail /var/log/syslog' | 'head -n 5' | 'head -n 3' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });
    });
  } finally {
    pop();
  }
}
