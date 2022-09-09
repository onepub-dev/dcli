@Timeout(Duration(minutes: 10))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/commands/install.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  group('Create Script ', () {
    test('Create script', () {
      TestFileSystem().withinZone((fs) {
        InstallCommand().initTemplates();
        final scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        const scriptName = 'extra.dart';
        final scriptPath = join(scriptDir, 'bin', scriptName);

        withEnvironment(() {
          'dcli create $scriptDir'.run;

          'dcli create $scriptPath'.run;
        }, environment: {
          DartProject.overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        DartScript.fromFile(scriptPath).doctor;
      });
    });

    test('Create script with --template', () {
      TestFileSystem().withinZone((fs) {
        InstallCommand().initTemplates();
        final scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        const scriptName = 'extra.dart';
        final scriptPath = join(scriptDir, 'bin', scriptName);

        withEnvironment(() {
          'dcli create $scriptDir'.run;

          'dcli create --template=cmd_args $scriptPath'.run;
        }, environment: {
          DartProject.overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        DartScript.fromFile(scriptPath).doctor;
      });
    });
  });
}
