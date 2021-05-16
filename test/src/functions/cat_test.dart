@Timeout(Duration(seconds: 600))

import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_utils.dart';

late String testFile;
void main() {
  Settings().setVerbose(enabled: true);
  t.group('Cat', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    t.test('Cat good ', () {
      withTempDir((testRoot) {
        print('PWD $pwd');
        testFile = join(testRoot, 'lines.txt');
        createLineFile(testFile, 10);

        final lines = <String?>[];
        cat(testFile, stdout: lines.add);
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('cat non-existing ', () {
      withTempDir((testRoot) {
        t.expect(() => cat('bad file.text'), t.throwsA(isA<CatException>()));
      });
    });
  });
}
