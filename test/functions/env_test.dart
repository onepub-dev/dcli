import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  Settings().debug_on = true;

  t.group('Environment', () {
    t.test('PATH', () {
      TestFileSystem().withinZone((fs) {
        t.expect(env('PATH').length, t.greaterThan(0));
      });
    });
  });
}
