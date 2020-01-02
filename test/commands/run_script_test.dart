@Timeout(Duration(seconds: 610))

import 'package:dshell/dshell.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';

void main() {
  test('Run hello world', () {
    TestZone().run(() {
      var results = <String>[];

      'test/test_scripts/hello_world.dart'.forEach((line) => results.add(line));

      // if clean hasn't been run then we have the results of a pub get in the the output.

      expect(getExpected(), anyOf([contains(results), equals(results)]));
    });
  });
}

List<String> getExpected() {
  return ['Hello World'];
}
