import 'package:test/test.dart';
import "package:dshell/dshell.dart";

void main() {
  Settings().debug_on = true;

  group("Environment", () {
    test("PATH", () {
      expect(env("PATH").length, greaterThan(0));
    });
  });
}
