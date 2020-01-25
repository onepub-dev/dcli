import 'dart:io';

import 'package:dshell/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();
  
  Settings().debug_on = true;

  t.group('FileSync', () {
    t.test('Append', () {
      TestZone().run(() {
        var testFile = join(TestPaths.TEST_ROOT, 'lines.txt');

        if (exists(testFile)) {
          delete(testFile);
        }
        var file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
        for (var i = 0; i < 10; i++) {
          file.append('Line ${i} is here');
        }
        file.close();

        var fstat = stat(file.path);

        t.expect(fstat.size, t.equals(150));
      });
    });

    t.test('Write', () {
      TestZone().run(() {
        var testFile = join(TestPaths.
        TEST_ROOT, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        var file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
        for (var i = 0; i < 10; i++) {
          file.append('Line ${i} is here');
        }
        var replacement = 'This is all that should be left';
        file.write(replacement, newline: null);
        file.close();

        var fstat = stat(file.path);

        t.expect(fstat.size, t.equals(replacement.length));
      });
    });
  });
}
