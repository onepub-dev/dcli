@Timeout(Duration(seconds: 600))

import 'package:dshell/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  group('Show Help', () {
    test('Help', () {
      TestFileSystem().withinZone((fs) {
        EntryPoint().process(['help']);
      });
    });
  });
}
