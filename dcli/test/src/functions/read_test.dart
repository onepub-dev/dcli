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
      Settings().setVerbose(enabled: true);
      expect(read(file).toList().length, equals(5));
    });
  });

  test('lines', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      Settings().setVerbose(enabled: true);
      expect(read(file).lines.length, equals(5));
    });
  });

  test('firstLine', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      Settings().setVerbose(enabled: true);
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
      Settings().setVerbose(enabled: true);
      expect(read(file).toParagraph(), equals('''
Line 1/5
Line 2/5
Line 3/5
Line 4/5
Line 5/5'''));
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
      Settings().setVerbose(enabled: true);
      final lines = <String>[];
      read(file).forEach(lines.add);
      expect(lines.length, equals(5));
      expect(lines.join(Platform().eol), equals('''
Line 1/5
Line 2/5
Line 3/5
Line 4/5
Line 5/5'''));
    });
  });
}
