@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/commands/compile.dart';

import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('compile ', () {
    TestFileSystem().withinZone((fs) {
      compile(join(fs.testScriptPath, 'general/bin/hello_world.dart'));
    });
  });

  test('compile package ', () {
    CompileCommand().compilePackage('onepub');
  });
}

void compile(String pathToScript) {
  TestFileSystem().withinZone((fs) {
    final pathToSript = join(fs.testScriptPath, 'general/bin/hello_world.dart');

    final dartScript = DartScript.fromFile(pathToSript);
    final exe = dartScript.exeName;
    final pathToExe = join(dirname(pathToScript), exe);

    try {
      if (exists(pathToExe)) {
        delete(pathToExe);
      }
      DartScript.fromFile(pathToSript).compile();
    } on DCliException catch (e) {
      print(e);
    }
    expect(exists(pathToExe), equals(true));
  });
}
