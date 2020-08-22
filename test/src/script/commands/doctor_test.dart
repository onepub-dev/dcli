@Timeout(Duration(seconds: 600))

import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/util/dcli_exception.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  test('dcli doctor', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        exit = EntryPoint().process(['doctor']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}
