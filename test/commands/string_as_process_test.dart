import 'package:test/test.dart';
import "package:dshell/dshell.dart";

void main() {
  group("StringAsProcess", () {
    List<String> lines = List();
    test("Run", () {
      var testFile = "test.text";

      if (exists(testFile)) {
        delete(testFile);
      }

      'touch test.text'.run;
      expect(exists(testFile), equals(true));
    });

    test("forEach", () {
      List<String> lines = List();

      print("pwd" + pwd);

      'tail -n 5 ../data/lines.txt'.forEach((line) => lines.add(line));

      expect(lines.length, equals(5));
    });
/*
    test("Pipe operator", () {
      'head -n 5 ../data/lines.txt' | 'tail -n 1'.run;
      expect(lines.length, equals(1));
    });
    */

    test("Lines", () {
      List<String> lines = 'head -n 5 /var/log/syslog'.lines;
      expect(lines.length, equals(5));
    });
  });
}
