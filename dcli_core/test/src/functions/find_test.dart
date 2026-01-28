/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('find stream', () {
    var count = 0;
    find(
      '*',
      includeHidden: true,
      workingDirectory: pwd,
      progress: (_) {
        count++;
        return true;
      },
    );
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
  });
}
