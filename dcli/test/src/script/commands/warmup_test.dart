@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(core.CopyTreeException)
void main() {
  group('warmup using DCli', () {
    test('warmup ', () async {
      await withTempDirAsync((tempDir) async {
        final projectPath = join(tempDir, 'general');
        final dcliRoot = dirname(DartProject.self.pathToProjectRoot);

        await core.withEnvironmentAsync(() async {
          final templateDir =
              join(tempDir, '.dcli', Settings.templateDir, 'project', 'simple');
          createDir(templateDir, recursive: true);
          copyTree(
            join(dcliRoot, Settings.templateDir, 'project', 'simple'),
            templateDir,
          );

          final project =
              DartProject.create(pathTo: projectPath, templateName: 'simple');
          await project.clean();
          await project.warmup();
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot,
          'HOME': tempDir,
        });

        expect(exists(join(projectPath, '.dart_tool')), equals(true));
        expect(exists(join(projectPath, 'pubspec.lock')), equals(true));
      });
    });
  });
}
