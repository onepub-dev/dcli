import 'package:test/test.dart' as t;

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  /// waiting of dart fixed to Uri.base
  t.test('Test Zone CWD', () {
    // Test for dart bug
    // https://github.com/dart-lang/sdk/issues/39796
    TestFileSystem().withinZone((fs) {
      t.expect(Uri.base, t.equals('.'));
    });
  }, skip: true);
}
