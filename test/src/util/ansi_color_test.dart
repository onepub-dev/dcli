@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/ansi.dart';
import 'package:dcli/src/util/ansi_color.dart';

import 'package:test/test.dart';

void main() {
  test('ansi colors', () {
    try {
      Ansi.isSupported = true;

      var redString = red('red');
      var expected = '\x1B[31;1mred\x1B[0m';

      expect(redString, expected);

      redString = red('red', bold: false);
      expected = '\x1B[31mred\x1B[0m';

      expect(redString, expected);

      Ansi.isSupported = false;

      redString = red('red');
      expected = 'red';

      expect(redString, expected);
    } finally {
      Ansi.resetEmitAnsi;
    }
  });

  test('clear line', () {
    Ansi.isSupported = true;
    print(green('Hellow worlrd'));
    print(green('Hellow worlrd', bold: false));

    print(red('hi',
        bold: false,
        background: AnsiColor(AnsiColor.code_yellow, bold: false)));
    print(red('hi', bold: false, background: AnsiColor.yellow));
    print(red('hi', bold: true, background: AnsiColor.yellow));

    print(orange('hello world', background: AnsiColor.black));

    print(red('hi', bold: true, background: AnsiColor.yellow));
    print(red('hi', bold: false, background: AnsiColor.yellow));

    print('ansi=${Ansi.isSupported}');
    var term = Terminal();
    // term.showCursor(show: false);
    for (var i = 0; i < 10; i++) {
      // term.clearLine();
      term.clearScreen();
      // term.startOfLine();
      echo(red('hellow $i')); // , newline: false);
    }
    // term.showCursor(show: true);
    print('');
    print('end');
  });
}
