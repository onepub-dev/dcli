import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group("Environment", () {
    t.test("PATH", () {
      TestZone().run(() {
        t.expect(env("PATH").length, t.greaterThan(0));
      });
    });
  });
}
