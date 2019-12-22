import 'package:test/test.dart' as t;

import '../util/test_fs_zone.dart';

void main() {
  t.test('Test Zone CWD', () {
    // Test for dart bug
    // https://github.com/dart-lang/sdk/issues/39796
    TestZone().run(() {
      t.expect(Uri.base, t.equals('.'));
    });
  });
}
