@t.Timeout(Duration(seconds: 600))
library;

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

import '../util/test_utils.dart';

void main() {
  t.group('Piping with ForEach ', () {
    final lines = <String?>[];

    t.test('For Each on string', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

        'tail -n 100 $linesFile'.forEach(lines.add);
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('forEach Single Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

        // TODO(bsutton): restore
        // lines.clear();
        // ('tail -n 100 $linesFile' | 'head -n 5').forEach(lines.add);

        // t.expect(lines.length, t.equals(5));
      });
    });

    t.test('forEach Double Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

        // TODO(bsutton): restore
        // lines.clear();
        // ('tail $linesFile' | 'head -n 5' | 'tail -n 2').forEach(lines.add);
        // t.expect(lines.length, t.equals(2));
      });
    });

    t.test('forEach Triple Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

// TODO(bsutton): restore
        // lines.clear();
        // ('tail $linesFile' | 'head -n 5' | 'head -n 3' | 'tail -n 2')
        //     .forEach(lines.add);
        // t.expect(lines.length, t.equals(2));
      });
    });
  });

  t.group('Piping with run ', () {
    // final lines = <String>[];

    t.test('run on string', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

        'tail -n 100 $linesFile'.run;
        //t.expect(lines.length, t.equals(10));
      });
    });

    t.test('run Single Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);
      });

// TODO(bsutton): restore
      // lines.clear();
      // ('tail -n 100 $linesFile' | 'head -n 5').run;

      //t.expect(lines.length, t.equals(5));
    });

    t.test('run Double Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

// TODO(bsutton): restore
        // lines.clear();
        // ('tail $linesFile' | 'head -n 5' | 'tail -n 2').run;
        //t.expect(lines.length, t.equals(2));
      });
    });

    t.test('run Triple Pipe', () async {
      await TestFileSystem().withinZone((fs) async {
        final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);
        createLineFile(linesFile, 10);

// TODO(bsutton): restore
        // lines.clear();
        // ('tail $linesFile' | 'head -n 5' | 'head -n 3' | 'tail -n 2').run;
        //t.expect(lines.length, t.equals(2));
      });
    });
  });
}
