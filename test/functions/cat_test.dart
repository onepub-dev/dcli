@Timeout(Duration(seconds: 600))

import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util.dart';
import '../util/test_file_system.dart';

String testFile;
void main() {

  Settings().debug_on = true;

  t.group('Cat', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    t.test('Cat good ', () {
      TestFileSystem().withinZone((fs) {
        print('PWD $pwd');
        testFile = join(fs.root, 'lines.txt');
        createLineFile(testFile, 10);

        var lines = <String>[];
        cat(testFile, stdout: (line) => lines.add(line));
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('cat non-existing ', () {
      TestFileSystem().withinZone((fs) {
        t.expect(() => cat('bad file.text'),
            t.throwsA(t.TypeMatcher<CatException>()));
      });
    });
  });
}
