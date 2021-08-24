import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('terminal ...', () async {
    print('Hello World');

    print('should be on line 1');
    print('should be on line 2');
    print('should be on line 3');
    final term = Terminal();
    print('Columns: ${term.columns}');
    print('Lines: ${term.rows}');
    print('Clearing screen in two seconds');

    term.overwriteLine('Overwritting 1');
    sleep(2);
    term.overwriteLine('Overwritting 2');
    sleep(2);
    term
      ..clearScreen()
      ..home()
      ..write('Clearing line in two seconds row: ${term.row}');
    sleep(2);
    term.clearLine();
    sleep(2);
    term.write('did line clear ${term.row}');
    sleep(2);
    term.home();
    print('hasTerminal: ${term.hasTerminal}');
    print('isAnsi: ${term.isAnsi}');
    print('should be on line 1');
    print('should be on line 2');
    print('should be on line 3');
    for (var i = 0; i < 20; i++) {
      term.overwriteLine('count $i');
      sleep(300, interval: Interval.milliseconds);
    }
    print('');
    print(red('and in red'));

    /// this code needs to be ran manually
    /// and observed to ensure it lays the screen
    /// out correctly.
  }, skip: true);
}
