@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */




import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('warmup using DCli', () {
    test('warmup ', () {
      TestFileSystem().withinZone((fs) {
        Settings().setVerbose(enabled: true);
        final projectPath = join(fs.fsRoot, 'test_script/general');
        DartProject.fromPath(projectPath)
          ..clean()
          ..warmup();

        expect(exists(join(projectPath, '.dart_tool')), equals(true));
        expect(exists(join(projectPath, '.packages')), equals(true));
        expect(exists(join(projectPath, 'pubspec.lock')), equals(true));
      });
    });
  });
}
