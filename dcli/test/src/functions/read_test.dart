/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('toList', () async{
    await withTempFileAsync ((file) async{
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).toList().length, equals(5));
    });
  });

  test('lines', () async{
    await withTempFileAsync ((file) async{
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).lines.length, equals(5));
    });
  });

  test('firstLine', () async{
    await withTempFileAsync ((file) async{
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).firstLine, equals('Line 1/5'));
    });
  });

  test('toParagraph', () async{
    await withTempFileAsync ((file) async{
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

  test('forEach', () async{
    await withTempFileAsync ((file) async{
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
}
