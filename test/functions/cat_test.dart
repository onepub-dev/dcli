import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util.dart';
import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

String testFile;
void main() {
  TestPaths();
  
  Settings().debug_on = true;

  t.group('Cat', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    t.test('Cat good ', () {
      TestZone().run(() {
        print('PWD $pwd');
        testFile = join(TestPaths.TEST_ROOT, 'lines.txt');
        createLineFile(testFile, 10);

        var lines = <String>[];
        cat(testFile, stdout: (line) => lines.add(line));
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('cat non-existing ', () {
      TestZone().run(() {
        t.expect(() => cat('bad file.text'),
            t.throwsA(t.TypeMatcher<CatException>()));
      });
    });
  });
}
