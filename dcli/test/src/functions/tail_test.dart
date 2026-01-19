/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(TouchException)
void main() {
  test('tail with more than required', () async {
    await withTempFileAsync((tmp) async {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }
      expect(tail(tmp, 1).toList().first, 'line 19');
    });
  });

  test('tail with less than required', () async {
    await withTempFileAsync((tmp) async {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }

      final list = tail(tmp, 40).toList();
      expect(list.length == 20, isTrue);
      expect(list.last, 'line 19');
    });
  });

  test('tail with godlocks zone', () async {
    await withTempFileAsync((tmp) async {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }

      final list = tail(tmp, 20).toList();
      expect(list.length == 20, isTrue);
      expect(list.last, 'line 19');
    });
  });

  test('tail with none', () async {
    await withTempFileAsync((tmp) async {
      touch(tmp);

      final list = tail(tmp, 20).toList();
      expect(list.isEmpty, isTrue);
    });
  });
}
