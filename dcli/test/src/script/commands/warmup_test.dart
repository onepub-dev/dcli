@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
void main() {
  group('warmup using DCli', () {
    test('warmup ', () async {
      await withTempDirAsync((tempDir) async {
        final projectPath = join(tempDir, 'general');
        final project =
            DartProject.create(pathTo: projectPath, templateName: 'simple');
        await project.clean();
        await project.warmup();

        expect(exists(join(projectPath, '.dart_tool')), equals(true));
        expect(exists(join(projectPath, 'pubspec.lock')), equals(true));
      });
    });
  });
}
