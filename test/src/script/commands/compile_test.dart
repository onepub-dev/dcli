@Timeout(Duration(seconds: 600))
import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

import '../../util/test_file_system.dart';

void main() {
  test('compile ', () {
    TestFileSystem().withinZone((fs) {
      compile(join(fs.testScriptPath, 'general/bin/hello_world.dart'));
    });
  });
}

void compile(String pathToScript) {
  TestFileSystem().withinZone((fs) {
    final script = join(fs.testScriptPath, 'general/bin/hello_world.dart');
    final exe = join(dirname(script), basenameWithoutExtension(script));

    try {
      if (exists(exe)) {
        delete(exe);
      }
      Script.fromFile(script).compile();
    } on DCliException catch (e) {
      print(e);
    }
    expect(exists(exe), equals(true));
  });
}
