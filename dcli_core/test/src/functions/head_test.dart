/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('head ...', () {
    withTempFile((pathToFile) {
      withOpenLineFile(pathToFile, (file) {
        for (var i = 0; i < 100; i++) {
          file.write('Line No. $i');
        }
      });
      // var stream = await head(pathToFile, 10);
    });
  });
}
