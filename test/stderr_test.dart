import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart' as t;

import 'util/test_fs_zone.dart';
import 'util/test_paths.dart';

void main() {
  TestPaths();

  Settings().debug_on = true;

  t.test('Stderr', () {
    TestZone().run(() {
      print('$pwd');

      t.expect(() => 'tail -n 5 badfilename.txt'.run,
          t.throwsA(t.TypeMatcher<DShellException>()));
    });
  });
}
