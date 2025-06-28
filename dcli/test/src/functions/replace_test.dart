/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('replace ...', () async {
    await withTempFileAsync((temp) async{
      temp
        ..write('abc123')
        ..append('def246');
      replace(temp, RegExp('[a-z]*'), 'xyz');

      expect(
        read(temp).toParagraph(),
        '''
xyz123
xyz246'''
            .replaceAll('\n', eol),
      );

      temp
        ..write('abc123')
        ..append('def246');
      replace(temp, 'abc', 'xyz');

      expect(
        read(temp).toParagraph(),
        '''
xyz123
def246'''
            .replaceAll('\n', eol),
      );
    });
  });
}
