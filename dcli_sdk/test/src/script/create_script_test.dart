@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_sdk/src/templates.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('Create Script ', () {
    test('Create script', () async {
      await TestFileSystem().withinZone((fs) async {
        /// make certain you have run 'dcli pack' before running this
        /// test if any templates have changed.
        initTemplates(print);
        final scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        const scriptName = 'extra.dart';
        final scriptPath = join(scriptDir, 'bin', scriptName);

        await withEnvironmentAsync(() async {
          'dcli -v create $scriptDir'.run;

          'dcli -v create $scriptPath'.run;
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        DartScript.fromFile(scriptPath).doctor;
      });
    });

    test('Create script with --template', () async {
      await TestFileSystem().withinZone((fs) async {
        initTemplates((line) {});
        final scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        const scriptName = 'extra.dart';
        final scriptPath = join(scriptDir, 'bin', scriptName);

        await withEnvironmentAsync(() async {
          'dcli create $scriptDir'.run;

          'dcli create --template=cmd_args $scriptPath'.run;
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        DartScript.fromFile(scriptPath).doctor;
      });
    });
  });
}
