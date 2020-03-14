@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

import 'util/test_file_system.dart';

void main() {

  t.test('Stderr', () {
    TestFileSystem().withinZone((fs) {
      print('$pwd');

      t.expect(() => 'tail -n 5 badfilename.txt'.run,
          t.throwsA(t.TypeMatcher<DShellException>()));
    });
  });
}
