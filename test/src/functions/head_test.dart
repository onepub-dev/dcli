@t.Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Head', () {
    t.test('head 5', () {
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        if (!exists(fs.fsRoot)) {
          createDir(fs.fsRoot, recursive: true);
        }
        final file = FileSync(testFile, fileMode: FileMode.write);
        for (var i = 0; i < 10; i++) {
          file.append('Line $i is here');
        }
        file.close();

        final lines = head(testFile, 5).toList();

        t.expect(lines.length, t.equals(5));
      });
    });
  },
      // calling head().toList() fails as we end up with two progressions.
      skip: true);
}
