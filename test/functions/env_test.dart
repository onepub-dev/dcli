import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

void main() {
  Settings().debug_on = true;

  t.group("Environment", () {
    t.test("PATH", () {
      t.expect(env("PATH").length, t.greaterThan(0));
    });
  });
}
