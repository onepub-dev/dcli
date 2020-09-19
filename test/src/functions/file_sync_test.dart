@t.Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('FileSync', () {
    t.test('Append', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.fsRoot, 'lines.txt');

        if (exists(testFile)) {
          delete(testFile);
        }
        var file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
        for (var i = 0; i < 10; i++) {
          file.append('Line $i is here');
        }
        file.close();

        var fstat = stat(file.path);

        t.expect(fstat.size, t.equals(150));
      });
    });

    t.test('Write', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.fsRoot, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        var file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
        for (var i = 0; i < 10; i++) {
          file.append('Line $i is here');
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
