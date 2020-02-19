// @Timeout(Duration(seconds: 600))

import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  TestFileSystem();

  group('Compile using DShell', () {
    test('compile examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          // setEnv('HOME', '/home/test');
          // createDir('/home/test', recursive: true);
          exit = EntryPoint().process(['compile', 'example/dsort.dart']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });

    test('compile -nc examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          // setEnv('HOME', '/home/test');
          // createDir('/home/test', recursive: true);
          exit = EntryPoint().process(['compile', '-nc', 'example/dsort.dart']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });

    test('compile  with a local pubspec', () {
      TestFileSystem().withinZone((fs) {
        var exit = -1;
        try {
          exit = EntryPoint().process(
              ['compile', 'test/test_scripts/local_pubspec/hello_world.dart']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    });
  });
}
