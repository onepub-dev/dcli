@Timeout(Duration(minutes: 10))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart' hide PubSpec;
import 'package:dcli/src/commands/install.dart';
import 'package:path/path.dart' hide equals;
import 'package:pubspec2/pubspec2.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('dart project directories', () async {
    expect(DartProject.fromPath(pwd).pathToProjectRoot, equals(truepath('.')));
    expect(
      DartProject.fromPath(pwd).pathToPubSpec,
      equals(truepath('pubspec.yaml')),
    );
    expect(
      DartProject.fromPath(pwd).pathToDartToolDir,
      equals(truepath('.dart_tool')),
    );
    expect(DartProject.fromPath(pwd).pathToToolDir, equals(truepath('tool')));
    expect(DartProject.fromPath(pwd).pathToBinDir, equals(truepath('bin')));
    expect(DartProject.fromPath(pwd).pathToTestDir, equals(truepath('test')));
  });

  group('Create Project ', () {
    test('Create project full with --template', () async {
      await TestFileSystem().withinZone((fs) async {
        InstallCommand().initTemplates();
        final pathToProject = fs.unitTestWorkingDir;

        const projectName = 'full_test';
        const mainScriptName = '$projectName.dart';
        final scriptPath = join(pathToProject, 'bin', mainScriptName);

        withEnvironment(() {
          'dcli create --template=full $projectName'
              .start(workingDirectory: pathToProject);
        }, environment: {
          DartProject.overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        expect(exists(scriptPath), isTrue);
        final project = DartProject.fromPath(pathToProject);
        expect(project.hasPubSpec, isTrue);
        final pubspec = await PubSpec.loadFile(project.pathToPubSpec);
        final executables = pubspec.executables;
        final mainScriptKey = basename(mainScriptName);
        expect(executables.containsKey(mainScriptKey), isTrue);
      });
    });
  });
}
