@Timeout(Duration(minutes: 30))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/dependency.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('Split Command', () {
    test('virtual pubspec', () {
      TestFileSystem().withinZone((fs) {
        var root = join('test', 'test_scripts', 'virtual_project');
        var scriptpath = join(root, 'cat.dart');
        var pubspecpath = join(root, 'pubspec.yaml');

        /// prepare the folder
        if (exists(pubspecpath)) {
          delete(pubspecpath);
        }
        EntryPoint().process(['split', scriptpath]);

        /// TODO: the rules have changed and cat.dart is no considered part
        /// of the dcli project and therefor the split command will
        /// no longer create a pubspec.
        expect(exists(pubspecpath), equals(true));

        var pubspec = PubSpecFile.fromFile(pubspecpath);
        expect('cat', equals(pubspec.name));
        expect(pubspec.dependencies.length, equals(3));
        expect(pubspec.dependencies[0].name, equals('args'));
        expect(pubspec.dependencies[1].name, equals('path'));
        expect(pubspec.dependencies[2].name, equals('dcli'));
      });
      // skipping until we have a chance to redefine how these tests should work.
    }, skip: true);

    test('annotation pubspec', () {
      TestFileSystem().withinZone((fs) {
        var root = join('test', 'test_scripts', 'annotated_project');
        var scriptpath = join(root, 'cat.dart');
        var pubspecpath = join(root, 'pubspec.yaml');

        /// restore the script.
        replace(scriptpath, '@disabled-pubspec.yaml', '@pubspec.yaml');

        if (exists(pubspecpath)) {
          delete(pubspecpath);
        }
        EntryPoint().process(['split', scriptpath]);

        expect(exists(pubspecpath), equals(true));

        var pubspec = PubSpecFile.fromFile(pubspecpath);
        expect(pubspec.name, equals('annotated_cat'));
        expect(pubspec.dependencies.length, equals(3));

        var dependencies = <Dependency>[];
        dependencies.add(Dependency.fromHosted('dcli', '^1.1.1'));
        dependencies.add(Dependency.fromHosted('path', '^1.7.0'));

        /// added via dependency injection.
        dependencies.add(Dependency.fromHosted('args', '^1.5.2'));

        expect(pubspec.dependencies, unorderedMatches(dependencies));
      });
    });
  });
}
