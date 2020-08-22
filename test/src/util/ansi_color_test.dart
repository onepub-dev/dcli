@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/ansi.dart';
import 'package:dcli/src/util/ansi_color.dart';

import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('ansi colors', () {
    TestFileSystem().withinZone((fs) {
      try {
        Ansi.isSupported = true;

        var redString = red('red');
        var expected = '\x1B[31mred\x1B[0m';

        expect(redString, expected);

        Ansi.isSupported = false;

        redString = red('red');
        expected = 'red';

        expect(redString, expected);
      } finally {
        Ansi.resetEmitAnsi;
      }
    });
  }, skip: true);

  test('clear line', () {
    TestFileSystem().withinZone((fs) {
      print('');
      var term = Terminal();
      term.showCursor(show: false);
      for (var i = 0; i < 10; i++) {
        term.clearLine();
        term.startOfLine();
        echo('hellow $i', newline: false);
      }
      term.showCursor(show: true);
      print('');
      print('end');
    });
  });
}
