@Timeout(Duration(seconds: 120))
import 'package:dcli/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  t.group('FileSync', () {
    t.test('Append', () {
      withTempDir((fsRoot) {
        final testFile = join(fsRoot, 'lines.txt');

        if (exists(testFile)) {
          delete(testFile);
        }
        final file = FileSync(testFile);
        for (var i = 0; i < 10; i++) {
          file.append('Line $i is here');
        }
        file.close();

        final fstat = stat(file.path);

        t.expect(fstat.size, t.equals(150));
      });
    });

    t.test('Write', () {
      withTempDir((fsRoot) {
        final testFile = join(fsRoot, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        final file = FileSync(testFile);
        for (var i = 0; i < 10; i++) {
          file.append('Line $i is here');
        }
        const replacement = 'This is all that should be left';
        file
          ..write(replacement, newline: null)
          ..close();

        final fstat = stat(file.path);

        t.expect(fstat.size, t.equals(replacement.length));
      });
    });
  });
}
