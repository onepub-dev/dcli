/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('find stream', () async {
    var count = 0;
    await for (final file in findAsync(
      '*',
      includeHidden: true,
      workingDirectory: pwd,
    )) {
      print(file);
      count++;
    }
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
  });
}
