import 'package:dcli/src/util/ansi.dart';
import 'package:dcli/src/util/ansi_color.dart';
import 'package:test/test.dart';

void main() {
  group('ansi', () {
    test('strip', () {
      expect(Ansi().strip(red('red')), equals('red'));
      expect(
          Ansi().strip('${red('red')} ${green('green')}'), equals('red green'));

      expect(Ansi().strip(red('red', bold: false)), equals('red'));
      expect(Ansi().strip(red('red', bold: false, background: AnsiColor.red)),
          equals('red'));
    });
  });
}
