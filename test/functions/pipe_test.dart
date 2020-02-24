@t.Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util.dart';
import '../util/test_file_system.dart';

void main() {

  Settings().debug_on = true;

  t.group('Piping with ForEach ', () {
    var lines = <String>[];

    t.test('For Each on string', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        'tail -n 100 $linesFile'.forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('forEach Single Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail -n 100 $linesFile' | 'head -n 5')
            .forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('forEach Double Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });
    });

    t.test('forEach Triple Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'head -n 3' | 'tail -n 2')
            .forEach((line) => lines.add(line));
        t.expect(lines.length, t.equals(2));
      });
    });
  });

  t.group('Piping with run ', () {
    var lines = <String>[];

    t.test('run on string', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        'tail -n 100 $linesFile'.run;
        //t.expect(lines.length, t.equals(10));
      });
    });

    t.test('run Single Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail -n 100 $linesFile' | 'head -n 5').run;

        //t.expect(lines.length, t.equals(5));
      });
    });

    t.test('run Double Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'tail -n 2').run;
        //t.expect(lines.length, t.equals(2));
      });
    });

    t.test('run Triple Pipe', () {
      TestFileSystem().withinZone((fs) {
        var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);
        createLineFile(linesFile, 10);

        lines.clear();
        ('tail $linesFile' | 'head -n 5' | 'head -n 3' | 'tail -n 2').run;
        //t.expect(lines.length, t.equals(2));
      });
    });
  });
}
