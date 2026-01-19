/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CopyException)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(MoveException)
/// @Throwing(TouchException)
void main() {
  test('move ...', () async {
    await withTempDirAsync((dir) async {
      touch('one.txt', create: true);
      touch('two.txt', create: true);

      expect(() => move('one.txt', 'two.txt'),
          equals(throwsA(isA<MoveException>())));

      move('one.txt', 'two.txt', overwrite: true);
      expect(!exists('one.txt'), isTrue);
      expect(exists('two.txt'), isTrue);
    });
  });
}
