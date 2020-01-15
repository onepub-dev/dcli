/*
@pubspec
name: hello_world.dart
dependencies:
  dshell: ^1.0.0
  money2: ^1.0.0
*/
import 'package:test/test.dart';
import 'package:dshell/dshell.dart' hide equals;

import '../util/test_fs_zone.dart';

void main() {
  // This is intended to demonstrate that we ouput data as it flows in
  // I'm not certain how to actually test that so for the moment this test is disabled.
  test('Slow', () {
    TestZone().run(() {
      print('$pwd');
      'bash /home/bsutton/git/dshell/test/test_scripts/slow.sh'
          .forEach((line) => print(line));
      expect(() => 'tail -n 5 badfilename.txt'.run,
          throwsA(TypeMatcher<DShellException>()));
    });
  }, skip: true);
}
