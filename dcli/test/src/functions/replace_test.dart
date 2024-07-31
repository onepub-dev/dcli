/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
