/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(TouchException)
void main() {
  test('toList', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).toList().length, equals(5));
    });
  });

  test('lines', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).lines.length, equals(5));
    });
  });

  test('firstLine', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).firstLine, equals('Line 1/5'));
    });
  });

  test('toParagraph', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(
          read(file).toParagraph(),
          equals('''
Line 1/5
Line 2/5
Line 3/5
Line 4/5
Line 5/5'''
              .replaceAll('\n', eol)));
    });
  });

  test('forEach', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      final lines = <String>[];
      read(file).forEach(lines.add);
      expect(lines.length, equals(5));
      expect(
          lines.join(eol),
          equals('''
Line 1/5
Line 2/5
Line 3/5
Line 4/5
Line 5/5'''
              .replaceAll('\n', eol)));
    });
  });

  test('handles utf8 content', () async {
    await withTempFileAsync((file) async {
      file
        ..append('Line 1 “smart quotes”')
        ..append('Line 2 – en dash')
        ..append('Line 3 ✓');
      final lines = read(file).toList();
      expect(lines.length, equals(3));
      expect(lines[0], equals('Line 1 “smart quotes”'));
      expect(lines[1], equals('Line 2 – en dash'));
      expect(lines[2], equals('Line 3 ✓'));
    });
  });
}
