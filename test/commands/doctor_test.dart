@Timeout(Duration(seconds: 600))

import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {

  test('dshell doctor', () {
    TestFileSystem().withinZone((fs) {
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
