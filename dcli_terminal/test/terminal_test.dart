/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_terminal/dcli_terminal.dart';
import 'package:test/test.dart';

void main() {
  test(
    'terminal ...',
    () async {
      print('Hello World');

      print('should be on line 1');
      print('should be on line 2');
      print('should be on line 3');
      final term = Terminal();
      print('Columns: ${term.columns}');
      print('Lines: ${term.rows}');
      print('Clearing screen in two seconds');

      term.overwriteLine('Overwritting 1');
      await sleep(2);
      term.overwriteLine('Overwritting 2');
      await sleep(2);
      term
        ..clearScreen()
        ..home()
        ..write('Clearing line in two seconds row: ${term.row}');
      await sleep(2);
      term.clearLine();
      await sleep(2);
      term.write('did line clear ${term.row}');
      await sleep(2);
      term.home();
      print('hasTerminal: ${term.hasTerminal}');
      print('isAnsi: ${term.isAnsi}');
      print('should be on line 1');
      print('should be on line 2');
      print('should be on line 3');
      for (var i = 0; i < 20; i++) {
        term.overwriteLine('count $i');
        await sleepMilli(300);
      }
      print('');
      print(red('and in red'));

      /// this code needs to be ran manually
      /// and observed to ensure it lays the screen
      /// out correctly.
    },
    skip: false,
  );
}

Future<void> sleep(int seconds) async {
  await Future.delayed(Duration(seconds: seconds), () {});
}

Future<void> sleepMilli(int millSeconds) async {
  await Future.delayed(Duration(milliseconds: millSeconds), () {});
}
