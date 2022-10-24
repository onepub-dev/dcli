@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/commands/compile.dart';

import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('compile ', () {
    TestFileSystem().withinZone((fs) {
      compile(join(fs.testScriptPath, 'general/bin/hello_world.dart'));
    });
  });

  test('compile package ', () {
    CompileCommand().compilePackage('dcli_unit_tester');
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
