//@Timeout(Duration(seconds: 610))

import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/util/runnable_process.dart';
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();
  
  test('Run hello world', () {
    TestZone().run(() {
      var results = <String>[];

      'dshell -v test/test_scripts/hello_world.dart'.forEach(
          (line) => results.add(line),
          stderr: (line) => printerr(line));

      // if clean hasn't been run then we have the results of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });
}

String getExpected() {
  return 'Hello World';
}
