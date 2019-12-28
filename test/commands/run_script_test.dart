@Timeout(Duration(seconds: 600))

import 'package:dshell/dshell.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';

void main() {
  test('Run hello world', () {
    TestZone().run(() {
      var results = <String>[];

      'test/test_scripts/hello_world.dart'.forEach((line) => results.add(line));

      expect(results, equals(getExpected()));
    });
  });
}

List<String> getExpected() {
  return ['Hello world'];
}
