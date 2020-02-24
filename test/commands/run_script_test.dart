@Timeout(Duration(seconds: 610))

import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/runnable_process.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Run hello world', () {
    TestFileSystem().withinZone((fs) {
      var results = <String>[];

      'dshell -v test/test_scripts/hello_world.dart'.forEach(
          (line) => results.add(line),
          stderr: (line) => printerr(line));

      // if clean hasn't been run then we have the results of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        // with a virtual pubspec
        exit =
            EntryPoint().process(['run', 'test/test_scripts/which.dart', 'ls']);
      } on DShellException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with a local pubspec', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);

        var projectPath =
            '$HOME/.dshell/cache/home/bsutton/git/dshell/test/test_scripts/local_pubspec/hello_world.project';
        if (exists(projectPath)) {
          deleteDir(projectPath);
        }
        exit = EntryPoint().process(
            ['run', 'test/test_scripts/local_pubspec/hello_world.dart']);
      } on DShellException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}

String getExpected() {
  return 'Hello World';
}
