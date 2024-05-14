@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('warmup using DCli', () {
    test('warmup ', () async {
      await TestFileSystem().withinZone((fs) async {
        final projectPath = join(fs.fsRoot, 'test_script/general');
        DartProject.fromPath(projectPath)
          ..clean()
          ..warmup();

        expect(exists(join(projectPath, '.dart_tool')), equals(true));
        expect(exists(join(projectPath, 'pubspec.lock')), equals(true));
      });
    });
  });
}
