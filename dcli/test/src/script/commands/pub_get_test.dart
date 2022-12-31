@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/src/script/dart_project.dart';
import 'package:dcli/src/script/pub_get.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('Pub Get', () {
    test('Do it', () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath =
            join(fs.testScriptPath, 'general/bin/hello_world.dart');
        final project = DartProject.fromPath(dirname(scriptPath));
        PubGet(project).run();
      });
    });
  });
}
