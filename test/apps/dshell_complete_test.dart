//@Timeout(Duration(seconds: 610))

import 'package:dshell/dshell.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  test('Run dshell_complete c', () {
    TestFileSystem().withinZone((fs) {
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
    TestFileSystem().withinZone((fs) {
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
      TestFileSystem().withinZone((fs) {
        var results = <String>[];

        touch(join(fs.root, '_test_a.dart'), create: true);
        touch(join(fs.root, '_test_ab.dart'), create: true);
        touch(join(fs.root, '_test_b.dart'), create: true);

        // make dshell_complete executable
        //chmod(755, 'bin/dshell_complete.dart');

        'dart bin/dshell_complete.dart dshell _test_a clean'
            .forEach((line) => results.add(line));

        // if clean hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.root, '_test_a.dart'));
        delete(join(fs.root, '_test_ab.dart'));
        delete(join(fs.root, '_test_b.dart'));
      });
    });

    test('Run dshell_complete clean _test_ab', () {
      TestFileSystem().withinZone((fs) {
        var results = <String>[];

        touch(join(fs.root, '_test_a.dart'), create: true);
        touch(join(fs.root, '_test_ab.dart'), create: true);
        touch(join(fs.root, '_test_b.dart'), create: true);

        // make dshell_complete executable
        //chmod(755, 'bin/dshell_complete.dart');

        'dart bin/dshell_complete.dart dshell _test_a clean'
            .forEach((line) => results.add(line));

        // if clean hasn't been run then we have the results of a pub get in the the output.
        var expected = ['_test_a.dart', '_test_ab.dart'];

        expect(results, unorderedEquals(expected));

        delete(join(fs.root, '_test_ab.dart'));
      });
    });
  });
}
