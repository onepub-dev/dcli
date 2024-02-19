/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('line file ...', () async {
    await withTempFileAsync((file) async {
      final buffer = <String>[];

      final src = File(file).openSync(mode: FileMode.write);
      for (var i = 0; i < 1000; i++) {
        src.writeStringSync('line $i\n');
      }
      src.closeSync();

      withOpenLineFile(file, (file) {
        file.readAll((line) {
          buffer.add(line);
          return true;
        });
      });

      expect(buffer.length, equals(1000));
    });
  });
}
