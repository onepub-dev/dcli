/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_terminal/dcli_terminal.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  group('ansi', () {
    test('strip', () {
      /// force ansi escapes on.
      Ansi.isSupported = true;
      expect(Ansi.strip(red('red')), equals('red'));
      expect(
        Ansi.strip('${red('red')} ${green('green')}'),
        equals('red green'),
      );

      expect(Ansi.strip(red('red', bold: false)), equals('red'));
      expect(
        Ansi.strip(red('red', bold: false, background: AnsiColor.red)),
        equals('red'),
      );

      /// Create encoded string that we know is has ansi codes
      /// This string
      /// '^[[32;1m1^[[0m:^[[38;5;208;1m0^[[0m:^[[31;1m0^[[0m:^[[34;1m0^[[0m test/bad_test.dart: Loading.';
      /// becomes
      const test2 = '''
1b5b33323b316d311b5b306d3a1b5b33383b353b3230383b316d301b5b306d3a1b5b33313b316d301b5b306d3a1b5b33343b316d301b5b306d20746573742f6261645f746573742e646172743a20546573747320636f6d706c657465642e''';

      final ansi = String.fromCharCodes(HEX.decode(test2));

      print('original $ansi');
      print('replaced ${Ansi.strip(ansi)}');

      expect(
        Ansi.strip(ansi),
        equals('1:0:0:0 test/bad_test.dart: Tests completed.'),
      );
    });
  });

  // test('hi test', () {
  //   Ansi.isSupported = true;

  //   var ansi = red('hi');

  //   doIt(ansi, RegExp('\x1b\\['));
  //   doIt(ansi, RegExp('\x1b\\[[0-9]'));
  //   doIt(ansi, RegExp('\x1b\\[[0-9;]+'));

  //   doIt(ansi, RegExp('\x1b\\[[0-9;]*[a-zA-Z]'));

  //   doIt(ansi, RegExp('\x1b\\['));
  //   doIt(ansi, RegExp('\x1b\\[[0-9;]+m'));

  //   doIt('123abc', RegExp('[a-z]+'));
  //   doIt("4457418557635128", RegExp(r"^(?:4[0-9]{12}(?:[0-9]{3})?)$"));
  // });
}

// int count = 0;
// void doIt(String ansi, RegExp regex) {
//   count++;

//   print('$count $ansi');
//   print('$count encoded ${HEX.encode(ansi.codeUnits)}');
//   print('$count hasMatch ${regex.hasMatch(ansi)}');

//   print('$count replaced ${ansi.replaceAll(regex, '')}');
//   // ignore: lines_longer_than_80_chars
//   print('$count encoded ${HEX.encode(ansi.replaceAll(regex, '')
//    .codeUnits)}');
// }
