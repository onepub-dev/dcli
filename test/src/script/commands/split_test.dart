@Timeout(Duration(minutes: 30))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('Split Command', () {
    test('virtual pubspec', () {
      TestFileSystem().withinZone((fs) {
        var root =
            join('test', 'test_scripts', 'split_command', 'virtual_project');

        var scriptpath = join(root, 'cat.dart');
        var pubspecpath = join(root, 'pubspec.yaml');

        /// prepare the folder
        if (!exists(root)) {
          createDir(root, recursive: true);
          if (exists(pubspecpath)) {
            delete(pubspecpath);
          }
        }
        EntryPoint().process(['split', scriptpath]);

        expect(exists(pubspecpath), equals(true));

        var pubspec = PubSpecFile.fromFile(pubspecpath);
        expect('cat', equals(pubspec.name));
        expect(pubspec.dependencies,
            equals(GlobalDependencies.defaultDependencies));
      });
    });
  });
}
