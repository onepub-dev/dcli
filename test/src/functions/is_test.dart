@Timeout(Duration(minutes: 10))
import 'dart:io';

import 'package:test/test.dart' hide isEmpty;
import 'package:dcli/dcli.dart' hide equals;

import '../util/test_file_system.dart';

void main() {
  group('iswritable', () {
    TestFileSystem().withinZone((fs) {
// owner, group, world, read, write execute

      test('owner', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 200 $one'.run;
        expect(isWritable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });

      test('group', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 020 $one'.run;
        expect(isWritable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });

      test('world', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 002 $one'.run;
        expect(isWritable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });
    });
  }, skip: Platform.isWindows);

  group('isReadable', () {
    TestFileSystem().withinZone((fs) {
// owner, group, world, read, write execute

      test('owner', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 400 $one'.run;
        expect(isReadable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isReadable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });

      test('group', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 040 $one'.run;
        expect(isReadable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isReadable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });

      test('world', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 004 $one'.run;
        expect(isReadable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isReadable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isExecutable(one), equals(false));

        delete(one);
      });
    });
  }, skip: Platform.isWindows);

  group('isExecutable', () {
    TestFileSystem().withinZone((fs) {
// owner, group, world, read, write execute

      test('owner', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 100 $one'.run;
        expect(isExecutable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isExecutable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));

        delete(one);
      });

      test('group', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 010 $one'.run;
        expect(isExecutable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isExecutable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));

        delete(one);
      });

      test('world', () {
        final one = fs.tempFile();
        touch(one, create: true);
        'chmod 001 $one'.run;
        expect(isExecutable(one), equals(true));
        'chmod 000 $one'.run;
        expect(isExecutable(one), equals(false));
        expect(isWritable(one), equals(false));
        expect(isReadable(one), equals(false));
        delete(one);
      });
    });
  }, skip: Platform.isWindows);

  group('isEmpty', () {
    test('isEmpty - good', () {
      final root = createTempDir();

      expect(isEmpty(root), isTrue);

      touch(join(root, 'a file'), create: true);

      expect(isEmpty(root), isFalse);
    });
  });
}
