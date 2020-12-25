@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('warmup using DCli', () {
    test('warmup ', () {
      TestFileSystem().withinZone((fs) {
        const projectPath = 'test/test_script/general';
        final project = DartProject.fromPath(projectPath);

        project.clean();
        project.warmup();

        expect(exists(join(projectPath, '.dart_tool')), equals(true));
        expect(exists(join(projectPath, '.packages')), equals(true));
        expect(exists(join(projectPath, 'pubspec.lock')), equals(true));
      });
    });
  });
}
