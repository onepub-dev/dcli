// @Timeout(Duration(seconds: 600))

import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  TestPaths();
  
  test('dshell doctor', () {
    TestZone().run(() {
      var exit = -1;
      try {
        exit = EntryPoint().process(['doctor']);
      } on DShellException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}
