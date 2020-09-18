@Timeout(Duration(seconds: 610))

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:dcli/src/util/runnable_process.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('Create and run a script', () {
    TestFileSystem().withinZone((fs) {
      var scriptParentPath = truepath(fs.testScriptPath, 'run_test');

      if (!exists(scriptParentPath)) {
        createDir(scriptParentPath, recursive: true);
      }
      var scriptPath = truepath(scriptParentPath, 'print_to_stdout.dart');

      // make certain our test script exists and is in a runnable state.
      '${DCliPaths().dcliName} -v create -fg $scriptPath'.run;

      var project = DartProject.fromPath(scriptParentPath);
      var script = project.createScript(basename(scriptPath));
      script.run([]);

      deleteDir(scriptParentPath, recursive: true);
    });
  });
  test('Run hello world', () {
    TestFileSystem().withinZone((fs) {
      var results = <String>[];

      '${DCliPaths().dcliName} -v test/test_scripts/general/bin/hello_world.dart'
          .forEach((line) => results.add(line), stderr: printerr);

      // if warmup hasn't been run then we have the results of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        var script =
            Script.fromFile('test/test_scripts/general/bin/which.dart');
        exit = script.run(['ls']);
      } on DCliException catch (e) {
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

        var script =
            Script.fromFile('test/test_scripts/local_pubspec/hello_world.dart');
        exit = script.run(['-v']);
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

        var script = Script.fromFile(
            'test/test_scripts/traditional_project/bin/traditional.dart');
        exit = script.run(['-v']);
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

        var script = Script.fromFile(
            'test/test_scripts/traditional_project/bin/nested/traditional.dart');
        exit = script.run(['-v']);
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

        var script = Script.fromFile(
            'test/test_scripts/traditional_project/example/traditional.dart');
        exit = script.run(['-v']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  }, skip: true);

  test('run  with traditional dart project structure - tool', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        print(pwd);

        var script = Script.fromFile(
            'test/test_scripts//traditional_project/tool/traditional.dart');
        exit = script.run(['-v']);
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
