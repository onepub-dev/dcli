@Timeout(Duration(seconds: 610))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_sdk/src/templates.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('Create and run a script', () async {
    await TestFileSystem().withinZone((fs) async {
      initTemplates(print);
      final projectPath = truepath(fs.tmpScriptPath, 'run_test');

      DartProject.create(pathTo: projectPath, templateName: 'simple');

      final exitCode =
          DartScript.fromFile(join(projectPath, 'bin', 'run_test.dart')).run();
      expect(exitCode, equals(0));
    });
  });
  test('Run hello world', () async {
    await TestFileSystem().withinZone((fs) async {
      final results = <String?>[];

      '${DCliPaths().dcliName} '
              '${join(fs.testScriptPath, 'general/bin/hello_world.dart')}'
          .forEach(results.add, stderr: printerr);

      // if warmup hasn't been run then we have the results of
      //  a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () async {
    await TestFileSystem().withinZone((fs) async {
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

  test('run  with traditional dart project structure - bin', () async {
    await TestFileSystem().withinZone((fs) async {
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

  test('run  with traditional dart project structure - nested bin', () async {
    await TestFileSystem().withinZone((fs) async {
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
    () async {
      await TestFileSystem().withinZone((fs) async {
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

  test('run  with traditional dart project structure - tool', () async {
    await TestFileSystem().withinZone((fs) async {
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
