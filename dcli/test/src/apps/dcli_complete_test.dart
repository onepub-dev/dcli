@Timeout(Duration(seconds: 600))
@TestOn('!windows')
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(TouchException)
void main() {
  test('Run dcli_complete c', () async {
    await TestFileSystem().withinZone((fs) async {
      final results = <String?>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli c'.start(
        workingDirectory: fs.fsRoot,
        progress: Progress(results.add),
      );

      final expected = ['clean', 'compile', 'create'];

      expect(_completionOutput(results, expected.length), equals(expected));
    });
  });

  test('Run dcli_complete cl', () async {
    await TestFileSystem().withinZone((fs) async {
      final results = <String?>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli cl'.start(
        workingDirectory: fs.fsRoot,
        progress: Progress(results.add),
      );

      final expected = ['clean'];

      expect(_completionOutput(results, expected.length), equals(expected));
    });
  });

  group('previous word', () {
    test('Run dcli_complete warmup _test_a', () async {
      await TestFileSystem().withinZone((fs) async {
        final results = <String?>[];

        touch(join(fs.fsRoot, '_test_a.dart'), create: true);
        touch(join(fs.fsRoot, '_test_ab.dart'), create: true);
        touch(join(fs.fsRoot, '_test_b.dart'), create: true);

        // make dcli_complete executable

        //chmod(755, 'bin/dcli_complete');

        try {
          'dcli_complete dcli _test_a warmup'.start(
            workingDirectory: fs.fsRoot,
            progress: Progress(results.add),
          );
        } on DCliException catch (_) {
          rethrow;
        }

        final expected = ['_test_a.dart', '_test_ab.dart'];

        expect(
          _completionOutput(results, expected.length),
          unorderedEquals(expected),
        );

        delete(join(fs.fsRoot, '_test_a.dart'));
        delete(join(fs.fsRoot, '_test_ab.dart'));
        delete(join(fs.fsRoot, '_test_b.dart'));
      });
    });

    test('Run dcli_complete warmup _test_ab', () async {
      await TestFileSystem().withinZone((fs) async {
        final results = <String?>[];

        touch(join(fs.fsRoot, '_test_a.dart'), create: true);
        touch(join(fs.fsRoot, '_test_ab.dart'), create: true);
        touch(join(fs.fsRoot, '_test_b.dart'), create: true);

        // make dcli_complete executable
        //chmod(755, 'bin/dcli_complete');

        'dcli_complete dcli _test_a warmup'.start(
          workingDirectory: fs.fsRoot,
          progress: Progress(results.add),
        );

        final expected = ['_test_a.dart', '_test_ab.dart'];

        expect(
          _completionOutput(results, expected.length),
          unorderedEquals(expected),
        );

        delete(join(fs.fsRoot, '_test_ab.dart'));
      });
    });
  });
}

/// A source-activated pub executable may run dependency resolution before
/// invoking the executable. Pub writes that status to stdout, followed by the
/// executable's output, so completion candidates are the trailing lines.
List<String?> _completionOutput(List<String?> output, int candidateCount) {
  if (output.length <= candidateCount) {
    return output;
  }

  return output.sublist(output.length - candidateCount);
}
