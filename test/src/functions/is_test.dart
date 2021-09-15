@Timeout(Duration(minutes: 10))
import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart' hide isEmpty;

import '../util/test_file_system.dart';

void main() {
  group(
    'iswritable',
    () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
// owner, group, world, read, write execute

        test('owner', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 200 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });

        test('group', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 020 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });

        test('world', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 002 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });
      });
    },
    skip: Platform.isWindows,
  );

  group(
    'isReadable',
    () {
      test('owner', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 400 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('group', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 040 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('world', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 004 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });
    },
    skip: Platform.isWindows,
  );

  group(
    'isExecutable',
    () {
      test('owner', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 100 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('group', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 010 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('world', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 001 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });
    },
    skip: Platform.isWindows,
  );

  group('isEmpty', () {
    test('isEmpty - good', () {
      withTempDir((root) {
        final root = createTempDir();

        expect(isEmpty(root), isTrue);

        touch(join(root, 'a file'), create: true);

        expect(isEmpty(root), isFalse);
      });
    });
  });
}
