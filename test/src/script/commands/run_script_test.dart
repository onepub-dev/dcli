@Timeout(Duration(seconds: 610))

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:dcli/src/util/runnable_process.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('Run hello world', () {
    TestFileSystem().withinZone((fs) {
      final results = <String>[];

      '${DCliPaths().dcliName} -v ${join(fs.testScriptPath, 'general/bin/hello_world.dart')}'
          .forEach((line) => results.add(line), stderr: printerr);

      // if warmup hasn't been run then we have the results of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        exit =
            Script.fromFile(join(fs.testScriptPath, 'general/bin/which.dart'))
                .run(['ls']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with traditional dart project structure - bin', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);

        exit = Script.fromFile(
                join(fs.testScriptPath, 'general/bin/hello_world.dart'))
            .run([]);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with traditional dart project structure - nested bin', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);

        exit = Script.fromFile(join(fs.testScriptPath,
                'traditional_project/bin/nested/traditional.dart'))
            .run([]);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with traditional dart project structure - example', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);
        exit = Script.fromFile(join(fs.testScriptPath,
                'traditional_project/example/traditional.dart'))
            .run([]);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });

    /// this script no longer exists after changing the rules about how we
    /// locate pubspec.yaml files.
    /// TODO: do we still need a test like this one?
  }, skip: true);

  test('run  with traditional dart project structure - tool', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);

        exit = Script.fromFile(join(
                fs.testScriptPath, 'traditional_project/tool/traditional.dart'))
            .run([]);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}

String getExpected() {
  return 'Hello World';
}
