//@Timeout(Duration(seconds: 610))

import 'package:dshell/dshell.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  test('Run dshell_complete c', () {
    TestZone().run(() {
      var results = <String>[];

      // make dshell_complete executable
      //chmod(755, 'bin/dshell_complete.dart');

      'dart bin/dshell_complete.dart dshell c'
          .forEach((line) => results.add(line));

      // if clean hasn't been run then we have the results of a pub get in the the output.
      var expected = ['cleanall', 'clean', 'compile', 'create'];

      expect(results, equals(expected));
    });
  });

  test('Run dshell_complete cl', () {
    TestZone().run(() {
      var results = <String>[];

      // make dshell_complete executable
      //chmod(755, 'bin/dshell_complete.dart');

      'dart bin/dshell_complete.dart dshell cl'
          .forEach((line) => results.add(line));

      // if clean hasn't been run then we have the results of a pub get in the the output.
      var expected = ['cleanall', 'clean'];

      expect(results, equals(expected));
    });
  });

  group('previous word', () {
    test('Run dshell_complete clean _test_a', () {
      TestZone().run(() {
        var results = <String>[];

        var paths = TestPaths('.');
        if (!exists(paths.testRoot)) {
          createDir(paths.testRoot, recursive: true);
        }
        var testRoot = '.';
        touch(join(testRoot, '_test_a.dart'), create: true);
        touch(join(testRoot, '_test_ab.dart'), create: true);
        touch(join(testRoot, '_test_b.dart'), create: true);

        // make dshell_complete executable
        //chmod(755, 'bin/dshell_complete.dart');

        'dart bin/dshell_complete.dart dshell _test_a clean'
            .forEach((line) => results.add(line));

        // if clean hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(testRoot, '_test_a.dart'));
        delete(join(testRoot, '_test_ab.dart'));
        delete(join(testRoot, '_test_b.dart'));
      });
    });

    test('Run dshell_complete clean _test_ab', () {
      TestZone().run(() {
        var results = <String>[];

        var paths = TestPaths('.');
        if (!exists(paths.testRoot)) {
          createDir(paths.testRoot, recursive: true);
        }
        var testRoot = '.';
        touch(join(testRoot, '_test_a.dart'), create: true);
        touch(join(testRoot, '_test_ab.dart'), create: true);
        touch(join(testRoot, '_test_b.dart'), create: true);

        // make dshell_complete executable
        //chmod(755, 'bin/dshell_complete.dart');

        'dart bin/dshell_complete.dart dshell _test_a clean'
            .forEach((line) => results.add(line));

        // if clean hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(testRoot, '_test_ab.dart'));
      });
    });
  });
}
