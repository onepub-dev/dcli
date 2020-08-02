@Timeout(Duration(minutes: 5))
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
// This is intended to demonstrate that we ouput data as it flows in
  // I'm not certain how to actually test that so for the moment this test is disabled.
  test('Slow', () {
    TestFileSystem().withinZone((fs) {
      print('$pwd');
      'bash /home/bsutton/git/dshell/test/test_scripts/slow.sh'.forEach(print);
      expect(() => 'tail -n 5 badfilename.txt'.run,
          throwsA(TypeMatcher<DShellException>()));
    });
  }, skip: true);
}
