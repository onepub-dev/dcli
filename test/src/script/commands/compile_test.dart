@Timeout(Duration(seconds: 600))
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

import '../../util/test_file_system.dart';

String script = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Compile using DCli', () {
    test('compile examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        compile('example/dsort.dart');
      });
    });

    test('compile -nc examples/dsort.dart', () {
      TestFileSystem().withinZone((fs) {
        var script = 'example/dsort.dart';
        compile(script);
      });
    });

    test('compile  with a local pubspec', () {
      TestFileSystem().withinZone((fs) {
        compile('test/test_scripts/general/bin/local_pubspec/hello_world.dart');
      });
    });
  });
}

void compile(String pathToScript) {
  var exe = join(dirname(script), basename(script));

  try {
    if (exists(exe)) {
      delete(exe);
    }
    Script.fromFile(script).compile();
  } on DCliException catch (e) {
    print(e);
  }
  expect(exists(exe), equals(true));
}
