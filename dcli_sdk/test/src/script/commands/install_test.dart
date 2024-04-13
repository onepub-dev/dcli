/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_sdk/src/commands/install.dart';
import 'package:dcli_sdk/src/templates.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group(
    'Install DCli',
    () {
      test(
        'warmup',
        () async {
          await withTestScope((testDir) async {
            expect(!core.Settings().isWindows || Shell.current.isPrivilegedUser,
                isTrue);
            //TestFileSystem(useCommonPath: false).withinZone((fs) {

            try {
              await InstallCommand().run([], []);
            } on DCliException catch (e) {
              print(e);
            }

            checkInstallStructure(testDir);

            // Now install over existing
            try {
              await Shell.current.install();
            } on DCliException catch (e) {
              print(e);
            }

            checkInstallStructure(testDir);
          });
        },
        tags: ['privileged'],
      );

      test('set env PATH Linux', () async {
        await withTestScope((testDir) async {
          final export = 'export PATH=\$PATH:${Settings().pathToDCliBin}';

          final profilePath = join(HOME, '.profile');
          if (exists(profilePath)) {
            final exportLines = read(profilePath).toList()
              ..retainWhere((line) => line.startsWith('export'));
            expect(exportLines, contains(export));
          }
        });
        // });
      });
    },
    skip: false,
  );

  test('initTemplates', () {
    initTemplates(print);
  });
}

void checkInstallStructure(String home) {
  expect(exists(truepath(home, '.dcli')), equals(true));
  expect(
      exists(truepath(home, '.dcli', 'template', 'project', 'custom')), isTrue);
  expect(exists(truepath(home, '.dcli', 'template', 'project')), isTrue);

  checkProjectStructure(home, 'simple');
  checkProjectStructure(home, 'cmd_args');
  checkProjectStructure(home, 'find');
  checkProjectStructure(home, 'simple');

  checkScriptStructure(home);
}

void checkScriptStructure(String home) {
  expect(exists(truepath(home, '.dcli', 'template', 'script')), equals(true));
  expect(exists(truepath(home, '.dcli', 'template', 'script', 'custom')),
      equals(true));
  expect(exists(truepath(home, '.dcli', 'template', 'script', 'simple')),
      equals(true));
  expect(
      exists(truepath(
          home, '.dcli', 'template', 'script', 'analysis_options.yaml')),
      equals(true));
  expect(exists(truepath(home, '.dcli', 'template', 'script', 'pubspec.lock')),
      equals(true));
  expect(exists(truepath(home, '.dcli', 'template', 'script', 'pubspec.yaml')),
      equals(true));
}

void checkProjectStructure(String home, String projectName) {
  final projectPath =
      truepath(home, '.dcli', 'template', 'project', projectName);
  expect(exists(projectPath), equals(true));

  final templates =
      find('*', includeHidden: true, workingDirectory: projectPath).toList();

  expect(
    templates,
    unorderedEquals(
      <String>[
        truepath(projectPath, 'CHANGELOG.md'),
        truepath(projectPath, 'pubspec.lock'),
        truepath(projectPath, 'analysis_options.yaml'),
        truepath(projectPath, 'README.md'),
        truepath(projectPath, 'pubspec.yaml'),
        truepath(projectPath, 'bin', 'main.dart'),
      ],
    ),
  );
}
