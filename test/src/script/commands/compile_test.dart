@Timeout(Duration(seconds: 600))

import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/util/dcli_exception.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

String script = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Compile using DCli', () {
    test('compile examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          // env['HOME'] = '/home/test';
          // createDir('/home/test', recursive: true);
          exit = EntryPoint().process(['compile', 'example/dsort.dart']);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });

    test('compile -nc examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          // env['HOME'] = '/home/test';
          // createDir('/home/test', recursive: true);
          exit = EntryPoint().process(['compile', '-nc', 'example/dsort.dart']);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });

    test('compile  with a local pubspec', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          exit = EntryPoint().process([
            'compile',
            'test/test_scripts/general/bin/local_pubspec/hello_world.dart'
          ]);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });
  });
}
