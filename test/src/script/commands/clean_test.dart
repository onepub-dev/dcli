@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/util/dcli_exception.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

String script = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Cleaning using DCli', () {
    test('clean with virtual pubspec', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          // with a virtual pubspec
          exit = EntryPoint().process(['clean', join('example', 'dsort.dart')]);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });

    test('clean  with a local pubspec', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          print(pwd);
          exit = EntryPoint().process(
              ['clean', 'test/test_scripts/local_pubspec/hello_world.dart']);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });
  });
}
