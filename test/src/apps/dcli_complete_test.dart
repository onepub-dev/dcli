@Timeout(Duration(seconds: 600))
@TestOn('!windows')
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/progress.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Run dcli_complete c', () {
    TestFileSystem().withinZone((fs) {
      final results = <String?>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli c'.start(
        workingDirectory: fs.fsRoot,
        progress: Progress(results.add),
      );

      // if warmup hasn't been run then we have the results of a
      //  pub get in the the output.
      final expected = ['clean', 'compile', 'create'];

      expect(results, equals(expected));
    });
  });

  test('Run dcli_complete cl', () {
    TestFileSystem().withinZone((fs) {
      final results = <String?>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli cl'.start(
        workingDirectory: fs.fsRoot,
        progress: Progress(results.add),
      );

      // if warmup hasn't been run then we have the results of a
      //  pub get in the the output.
      final expected = ['clean'];

      expect(results, equals(expected));
    });
  });

  group('previous word', () {
    test('Run dcli_complete warmup _test_a', () {
      TestFileSystem(installDcli: false).withinZone((fs) {
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

        // if warmup hasn't been run then we have the results of
        // a pub get in the the output.
        final expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.fsRoot, '_test_a.dart'));
        delete(join(fs.fsRoot, '_test_ab.dart'));
        delete(join(fs.fsRoot, '_test_b.dart'));
      });
    });

    test('Run dcli_complete warmup _test_ab', () {
      TestFileSystem().withinZone((fs) {
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

        // if warmup hasn't been run then we have the results of
        // a pub get in the the output.
        final expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.fsRoot, '_test_ab.dart'));
      });
    });
  });
}
