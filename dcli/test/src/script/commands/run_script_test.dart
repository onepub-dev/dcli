@Timeout(Duration(seconds: 610))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('Run hello world', () async {
    await TestFileSystem().withinZone((fs) async {
      final results = <String?>[];

      '${DCliPaths().dcliName} '
              '${join(fs.testScriptPath, 'general/bin/hello_world.dart')}'
          .forEach(results.add, stderr: printerr);

      // if warmup hasn't been run then we have the results
      //  of a pub get in the the output.

      expect(results, anyOf([contains(getExpected()), equals(getExpected())]));
    });
  });

  test('run with traditional dart project structure - bin', () async {
    await TestFileSystem().withinZone((fs) async {
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

  test('run with traditional dart project structure - nested bin', () async {
    await TestFileSystem().withinZone((fs) async {
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
    () async {
      await TestFileSystem().withinZone((fs) async {
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
      /// TODO(bsutton): do we still need a test like this one?
    },
    skip: true,
  );

  test('run with traditional dart project structure - tool', () async {
    await TestFileSystem().withinZone((fs) async {
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
