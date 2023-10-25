@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/templates.dart';
import 'package:path/path.dart' hide equals;
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  group('Create Project ', () {
    test('Create project full with --template', () async {
      await TestFileSystem().withinZone((fs) async {
        initTemplates((_) {});
        final pathToProject = fs.unitTestWorkingDir;

        const projectName = 'full_test';
        const mainScriptName = '$projectName.dart';
        final scriptPath = join(pathToProject, 'bin', mainScriptName);

        await withEnvironment(() async {
          'dcli create --template=full $projectName'
              .start(workingDirectory: pathToProject);
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        expect(exists(scriptPath), isTrue);
        final project = DartProject.fromPath(pathToProject);
        expect(project.hasPubSpec, isTrue);
        final pubspec = PubSpec.loadFromPath(project.pathToPubSpec);
        final executables = pubspec.executables;
        final mainScriptKey = basenameWithoutExtension(mainScriptName);
        expect(executables.exists(mainScriptKey), isTrue);
        expect(executables[mainScriptKey]!.scriptPath,
            equals(join('bin', '$mainScriptKey.dart')));
      });
    });

    // });
  });
}
