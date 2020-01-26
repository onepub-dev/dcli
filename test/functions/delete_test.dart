import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();

  Settings().debug_on = true;

  t.group('Delete', () {
    t.test('delete ', () {
      TestZone().run(() {
        var testFile = join(TestPaths.TEST_ROOT, 'lines.txt');
        if (!exists(dirname(testFile))) {
          createDir(dirname(testFile), recursive: true);
        }

        touch(testFile, create: true);

        delete(testFile);
        t.expect(!exists(testFile), t.equals(true));
      });
    });

    t.test('delete non-existing ', () {
      TestZone().run(() {
        var testFile = join(TestPaths.TEST_ROOT, 'lines.txt');
        touch(testFile, create: true);
        delete(testFile);

        t.expect(() => delete(testFile),
            t.throwsA(t.TypeMatcher<DeleteException>()));
      });
    });
  });
}
