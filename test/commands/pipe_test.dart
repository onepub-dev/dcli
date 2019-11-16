import 'package:test/test.dart';
import "package:dshell/dshell.dart";

void main() {
  group("Piping", () {
    List<String> lines = List();
    test("Single Pipe", () {
      ('tail /var/log/syslog' | 'head -n 5').forEach((line) => lines.add(line));

      expect(lines.length, equals(5));
    });

    test("Double Pipe", () {
      lines.clear();
      ('tail /var/log/syslog' | 'head -n 5' | 'tail -n 2')
          .forEach((line) => lines.add(line));
      expect(lines.length, equals(2));
    });

    test("Triple Pipe", () {
      lines.clear();
      ('tail /var/log/syslog' | 'head -n 5' | 'head -n 3' | 'tail -n 2')
          .forEach((line) => lines.add(line));
      expect(lines.length, equals(2));
    });
  });
}
