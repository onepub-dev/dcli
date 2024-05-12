@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:test/test.dart';

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
      //    await TestFileSystem().withinZone((fs) async {
//        InstallCommand().initTemplates();

      final dcliRoot = dirname(DartProject.self.pathToProjectRoot);

      await core.withTempDirAsync((tempDir) async {
        const projectName = 'full_test';
        final pathToProject = join(tempDir, projectName);

        const mainScriptName = '$projectName.dart';
        final scriptPath = join(pathToProject, 'bin', mainScriptName);

        final templatePath = join(dcliRoot, Settings.templateDir);
        await core.withEnvironmentAsync(() async {
          final testTemplateDir =
              join(tempDir, '.dcli', Settings.templateDir, 'project', 'full');
          createDir(testTemplateDir, recursive: true);

          /// copy the dev templates into the temp template path
          /// so we are always running with a current version of the templates.
          copyTree(join(templatePath, 'project', 'full'), testTemplateDir);
          DartProject.create(pathTo: pathToProject, templateName: 'full');
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot,
          'HOME': tempDir
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

  test('findProject', () async {
    await core.withTempDirAsync((tempDir) async {
      final pathToTools = join(tempDir, '.dart_tools');
      createDir(pathToTools);

      join(tempDir, 'pubspec.yaml').write('''
name: test
''');

      /// start search from sub-directory of actual project.
      /// It should return the actual project path.
      expect(DartProject.findProject(pathToTools)!.pathToProjectRoot, tempDir);
    });
  });
}
