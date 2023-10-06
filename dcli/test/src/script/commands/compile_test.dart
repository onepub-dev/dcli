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
  test('compile ', () async {
    await TestFileSystem().withinZone((fs) async {
      await compile(join(fs.testScriptPath, 'general/bin/hello_world.dart'));
    });
  });
}

Future<void> compile(String pathToScript) async {
  await TestFileSystem().withinZone((fs) async {
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
