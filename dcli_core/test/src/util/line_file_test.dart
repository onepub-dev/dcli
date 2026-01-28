/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
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
