/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('head ...', () async {
    await withTempFileAsync((pathToFile) async {
      await withOpenLineFile(pathToFile, (file) async {
        for (var i = 0; i < 100; i++) {
          file.write('Line No. $i');
        }
      });
      // var stream = await head(pathToFile, 10);
    });
  });
}
