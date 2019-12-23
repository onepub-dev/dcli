@Timeout(Duration(seconds: 600))

import 'package:dshell/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';

// TODO: when ran this generates the error:
// Unhandled exception:
// FileSystemException: Couldn't determine file type of stdin (fd 0), path = ''
void main() {
  test('Run hello world', () {
    TestZone().run(() {
      var exitCode =
          EntryPoint().process(['test/test_scripts/hello_world.dart', 'world']);

      expect(exitCode, equals(0));
    });
  });
}
