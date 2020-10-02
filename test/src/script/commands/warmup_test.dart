@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('warmup using DCli', () {
    test('warmup ', () {
      TestFileSystem().withinZone((fs) {
        var project = DartProject.fromPath('example');

        project.clean();
        project.warmup();

        expect(exists(join('example', '.dart_tool')), equals(true));
        expect(exists(join('example', '.packages')), equals(true));
        expect(exists(join('example', 'pubspec.lock')), equals(true));
      });
    });
  });
}
