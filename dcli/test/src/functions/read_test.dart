/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('toList', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).toList().length, equals(5));
    });
  });

  /// TODO: this test fails as read().lines returns an empty list
  /// this needs to be fixed as part of the rewrite of Progress.
  test('lines', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).lines.length, equals(5));
    });
  }, skip: true);

  test('firstLine', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).firstLine, equals('Line 1/5'));
    });
  });

  test('toParagraph', () {
    withTempFile((file) {
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
              .replaceAll('\n', Platform().eol)));
    });
  });

  test('forEach', () {
    withTempFile((file) {
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
          lines.join(Platform().eol),
          equals('''
Line 1/5
Line 2/5
Line 3/5
Line 4/5
Line 5/5'''
              .replaceAll('\n', Platform().eol)));
    });
  });
}
