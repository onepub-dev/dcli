/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('dart script ...', () async {
    expect(
      DartScript.stripDartVersionSuffix('pub_release.dart-2.13.0'),
      equals('pub_release.dart'),
    );

    expect(
      DartScript.stripDartVersionSuffix('pub_release.dart'),
      equals('pub_release.dart'),
    );

    expect(
      DartScript.stripDartVersionSuffix(
        p.join('some', 'path', 'pub_release.dart-2.13.0'),
      ),
      equals(p.join('some', 'path', 'pub_release.dart')),
    );

    expect(
      DartScript.stripDartVersionSuffix(
        p.join('some', 'path', 'pub_release.dart'),
      ),
      equals(p.join('some', 'path', 'pub_release.dart')),
    );

    expect(
      DartScript.fromFile('dart_script_test.dart').scriptName,
      equals('dart_script_test.dart'),
    );
  });

  group('basename', () {});
  group('pathToScript', () {
    const packageName = 'dcli_unit_tester';
    final pathToTestScript = truepath(
        'test', 'test_script', packageName, 'bin', 'dcli_unit_tester.dart');

    test('within unit test', () {
      // within a unit test
      expect(DartScript.self.pathToScript,
          truepath('test', 'src', 'script', 'dart_script_test.dart'));
    });

    test('jit script', () {
      final dcliProjectRoot = DartProject.self.pathToProjectRoot;
      final projectRoot =
          join(dcliProjectRoot, 'test', 'test_script', 'dcli_unit_tester');
      chmod(pathToTestScript, permission: '740');
      DartScript.fromFile(pathToTestScript).runPubGet();
      final result = 'dart $pathToTestScript --script'
          .start(progress: Progress.capture(), nothrow: true)
          .toList();
      expect(result.length, equals(13));
      var line = 0;
      expect(result[line++], equals('basename, dcli_unit_tester'));
      expect(result[line++], equals('exeName, dcli_unit_tester'));
      expect(result[line++], equals('isCompiled, false'));
      expect(result[line++], equals('isInstalled, false'));
      expect(result[line++], equals('isPubGlobalActivated, false'));
      expect(result[line++], equals('isReadyToRun, true'));
      expect(
          result[line++],
          equals('pathToExe, '
              '${join(projectRoot, 'bin', 'dcli_unit_tester')}'));
      expect(
          result[line++],
          equals('pathToInstalledExe, '
              '${join(HOME, '.dcli', 'bin', 'dcli_unit_tester')}'));
      expect(result[line++], equals('pathToProjectRoot, $projectRoot'));
      expect(
          result[line++],
          equals('pathToPubSpec, '
              '${join(projectRoot, 'pubspec.yaml')}'));
      expect(
          result[line++],
          equals('pathToScript, '
              '${join(projectRoot, 'bin', 'dcli_unit_tester.dart')}'));
      expect(
          result[line++],
          equals('pathToScriptDirectory, '
              '${join(projectRoot, 'bin')}'));
      expect(result[line++], equals('scriptName, dcli_unit_tester.dart'));
    });

    test('compiled script', () {
      final script = DartScript.fromFile(pathToTestScript)
        ..runPubGet()
        ..compile(workingDirectory: dirname(pathToTestScript));

      final pathToCompiledScript = join(dirname(pathToTestScript),
          basenameWithoutExtension(pathToTestScript));

      /// check that the path and script name are what we expect.
      expect(dirname(pathToCompiledScript), equals(dirname(script.pathToExe)));
      // on windows we add .exe as the extension so compare compiled script
      // name sans the extension.
      expect(basenameWithoutExtension(pathToCompiledScript),
          equals(basenameWithoutExtension(script.exeName)));

      if (Platform.isWindows) {
        expect('.exe', equals(extension(script.exeName)));
      }

      expect(exists(script.pathToExe), isTrue);

      // run compiled script
      final result =
          script.pathToExe.start(progress: Progress.capture()).toList();

      expect(result.length, equals(1));
      expect(result[0], equals(script.pathToExe));
    });

    test('globally activated script', () {
      PubCache().globalActivate(packageName);

      final result =
          '$packageName --script'.start(progress: Progress.capture()).toList();

      final dcliProjectRoot = DartProject.self.pathToProjectRoot;
      final projectRoot =
          join(dcliProjectRoot, 'test', 'test_script', 'dcli_unit_tester');

      expect(result.length, equals(13));
      var line = 0;
      expect(result[line++], equals('basename, dcli_unit_tester'));
      expect(result[line++], equals('exeName, dcli_unit_tester'));
      expect(result[line++], equals('isCompiled, false'));
      expect(result[line++], equals('isInstalled, true'));
      expect(result[line++], equals('isPubGlobalActivated, false'));
      expect(result[line++], equals('isReadyToRun, true'));
      expect(
          result[line++],
          equals('pathToExe, '
              '${join(projectRoot, 'bin', 'dcli_unit_tester')}'));
      expect(
          result[line++],
          equals('pathToInstalledExe, '
              '${join(HOME, '.dcli', 'bin', 'dcli_unit_tester')}'));
      expect(result[line++], equals('pathToProjectRoot, $projectRoot'));
      expect(
          result[line++],
          equals('pathToPubSpec, '
              '${join(projectRoot, 'pubspec.yaml')}'));
      expect(
          result[line++],
          equals('pathToScript, '
              '${join(projectRoot, 'bin', 'dcli_unit_tester.dart')}'));
      expect(
          result[line++],
          equals('pathToScriptDirectory, '
              '${join(projectRoot, 'bin')}'));
      expect(result[line++], equals('scriptName, dcli_unit_tester.dart'));
      expect(result.length, equals(1));
    });
  });
}
