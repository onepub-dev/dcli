import 'package:dshell/dshell.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:test/test.dart' as t;

void main() {
  Settings().debug_on = true;

  t.test("Stderr", () {
    print("$pwd");

    ;

    t.expect(() => 'tail -n 5 badfilename.txt'.run,
        t.throwsA(t.TypeMatcher<DShellException>()));
  });
}
