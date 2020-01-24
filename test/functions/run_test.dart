import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;
  t.group('RunCommand', () {
    t.test('Does command run', () {
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Does command write output to stdout', () {
      TestZone().run(() {
        var script = join('test', 'test_scripts', 'run_echo.dart');

        if (!exists(basename(script))) {
          createDir(basename(script));
        }

        // make certain our test script will run
        'dshell create $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = 'dshell $script'.toList();

        var expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });
  });
}
