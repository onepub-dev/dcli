@Timeout(Duration(seconds: 610))

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('Create and run a script', () {
    TestFileSystem().withinZone((fs) {
      final projectPath = truepath(fs.tmpScriptPath, 'run_test');

      if (!exists(projectPath)) {
        createDir(projectPath, recursive: true);
      }
      final scriptPath = truepath(projectPath, 'print_to_stdout.dart');
      if (exists(scriptPath)) {
        delete(scriptPath);
      }

      DartProject.create(pathTo: projectPath, templateName: 'simple');

      DartScript.fromFile(join(projectPath, 'bin', 'simple.dart'))
        ..runPubGet()
        ..run();

      deleteDir(projectPath);
    });
  });
  test('Run hello world', () {
    TestFileSystem().withinZone((fs) {
      final results = <String?>[];

      '${DCliPaths().dcliName} '
              '${join(fs.testScriptPath, 'general/bin/hello_world.dart')}'
          .forEach(results.add, stderr: printerr);

      // if warmup hasn't been run then we have the results of
      //  a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        final script = DartScript.fromFile(
          join(fs.testScriptPath, 'general/bin/which.dart'),
        );
        exit = script.run(args: ['ls']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with traditional dart project structure - bin', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        final script = DartScript.fromFile(
          join(
            fs.testScriptPath,
            'traditional_project/bin/traditional.dart',
          ),
        );
        exit = script.run(args: ['-v']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run  with traditional dart project structure - nested bin', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        final script = DartScript.fromFile(
          join(
            fs.testScriptPath,
            'traditional_project/bin/nested/traditional.dart',
          ),
        );
        exit = script.run(args: ['-v']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test(
    'run  with traditional dart project structure - example',
    () {
      TestFileSystem().withinZone((fs) {
        int? exit = -1;
        try {
          print(pwd);

          final script = DartScript.fromFile(
            join(
              fs.testScriptPath,
              'traditional_project/example/traditional.dart',
            ),
          );
          exit = script.run(args: ['-v']);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });
    },
    skip: true,
  );

  test('run  with traditional dart project structure - tool', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        final script = DartScript.fromFile(
          join(
            fs.testScriptPath,
            'traditional_project/tool/traditional.dart',
          ),
        );
        exit = script.run(args: ['-v']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}

String getExpected() => 'Hello World';
