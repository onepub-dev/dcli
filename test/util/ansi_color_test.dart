@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/ansi_color.dart';

import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('ansi colors', () {
    TestFileSystem().withinZone((fs) {
      try {
        AnsiColor.emitAnsi = true;

        var redString = red('red');
        var expected = '\x1B[31mred\x1B[0m';

        expect(redString, expected);

        AnsiColor.emitAnsi = false;

        redString = red('red');
        expected = 'red';

        expect(redString, expected);
      } finally {
        AnsiColor.resetEmitAnsi;
      }
    });
  }, skip: false);
}
