@Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Delete', () {
    t.test('delete ', () {
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'lines.txt');
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
        final testFile = join(fs.fsRoot, 'lines.txt');
        touch(testFile, create: true);
        delete(testFile);

        t.expect(() => delete(testFile),
            t.throwsA(isA<DeleteException>()));
      });
    });
  });
}
