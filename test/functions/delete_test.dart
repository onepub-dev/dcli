@Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Delete', () {
    t.test('delete ', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'lines.txt');
        if (!exists(dirname(testFile))) {
          createDir(dirname(testFile), recursive: true);
        }

        touch(testFile, create: true);

        delete(testFile);
        t.expect(!exists(testFile), t.equals(true));
      });
    });

    t.test('delete non-existing ', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'lines.txt');
        touch(testFile, create: true);
        delete(testFile);

        t.expect(() => delete(testFile),
            t.throwsA(t.TypeMatcher<DeleteException>()));
      });
    });
  });
}
