@Timeout(Duration(seconds: 610))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('Run hello world', () {
    TestFileSystem().withinZone((fs) {
      final results = <String?>[];

      '${DCliPaths().dcliName} '
              '${join(fs.testScriptPath, 'general/bin/hello_world.dart')}'
          .forEach(results.add, stderr: printerr);

      // if warmup hasn't been run then we have the results
      //  of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with virtual pubspec', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        exit = DartScript.fromFile(
          join(fs.testScriptPath, 'general/bin/which.dart'),
        ).run(args: ['ls']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run with traditional dart project structure - bin', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        exit = DartScript.fromFile(
          join(fs.testScriptPath, 'general/bin/hello_world.dart'),
        ).run();
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test('run with traditional dart project structure - nested bin', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        exit = DartScript.fromFile(
          join(
            fs.testScriptPath,
            'traditional_project/bin/nested/traditional.dart',
          ),
        ).run();
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });

  test(
    'run with traditional dart project structure - example',
    () {
      TestFileSystem().withinZone((fs) {
        int? exit = -1;
        try {
          print(pwd);
          exit = DartScript.fromFile(
            join(
              fs.testScriptPath,
              'traditional_project/example/traditional.dart',
            ),
          ).run();
        } on DCliException catch (e) {
          print(e);
        }
        expect(exit, equals(0));
      });

      /// this script no longer exists after changing the rules about how we
      /// locate pubspec.yaml files.
      // ignore: flutter_style_todos
      /// TODO: do we still need a test like this one?
    },
    skip: true,
  );

  test('run with traditional dart project structure - tool', () {
    TestFileSystem().withinZone((fs) {
      int? exit = -1;
      try {
        print(pwd);

        exit = DartScript.fromFile(
          join(
            fs.testScriptPath,
            'traditional_project/tool/traditional.dart',
          ),
        ).run();
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}

String getExpected() => 'Hello World';
