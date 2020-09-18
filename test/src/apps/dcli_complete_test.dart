@Timeout(Duration(seconds: 600))
@TestOn('!windows')
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/progress.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Run dcli_complete c', () {
    TestFileSystem().withinZone((fs) {
      var results = <String>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli c'.start(
        workingDirectory: fs.root,
        progress: Progress((line) => results.add(line)),
      );

      // if warmup hasn't been run then we have the results of a pub get in the the output.
      var expected = ['warmup', 'compile', 'create'];

      expect(results, equals(expected));
    });
  });

  test('Run dcli_complete cl', () {
    TestFileSystem().withinZone((fs) {
      var results = <String>[];

      // make dcli_complete executable
      //chmod(755, 'bin/dcli_complete');

      'dcli_complete dcli cl'.start(
        workingDirectory: fs.root,
        progress: Progress((line) => results.add(line)),
      );

      // if warmup hasn't been run then we have the results of a pub get in the the output.
      var expected = ['warmup'];

      expect(results, equals(expected));
    });
  });

  group('previous word', () {
    test('Run dcli_complete warmup _test_a', () {
      TestFileSystem().withinZone((fs) {
        var results = <String>[];

        touch(join(fs.root, '_test_a.dart'), create: true);
        touch(join(fs.root, '_test_ab.dart'), create: true);
        touch(join(fs.root, '_test_b.dart'), create: true);

        // make dcli_complete executable

        //chmod(755, 'bin/dcli_complete');

        try {
          'dcli_complete dcli _test_a warmup'.start(
            workingDirectory: fs.root,
            progress: Progress((line) => results.add(line)),
          );
        } on DCliException catch (_) {
          rethrow;
        }

        // if warmup hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.root, '_test_a.dart'));
        delete(join(fs.root, '_test_ab.dart'));
        delete(join(fs.root, '_test_b.dart'));
      });
    });

    test('Run dcli_complete warmup _test_ab', () {
      TestFileSystem().withinZone((fs) {
        var results = <String>[];

        touch(join(fs.root, '_test_a.dart'), create: true);
        touch(join(fs.root, '_test_ab.dart'), create: true);
        touch(join(fs.root, '_test_b.dart'), create: true);

        // make dcli_complete executable
        //chmod(755, 'bin/dcli_complete');

        'dcli_complete dcli _test_a warmup'.start(
          workingDirectory: fs.root,
          progress: Progress((line) => results.add(line)),
        );

        // if warmup hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.root, '_test_ab.dart'));
      });
    });
  });
}
