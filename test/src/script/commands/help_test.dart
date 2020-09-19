@Timeout(Duration(seconds: 600))

import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('Show Help', () {
    test('Help', () {
      TestFileSystem().withinZone((fs) {
        EntryPoint().process(['help']);
      });
    });
  });
}
