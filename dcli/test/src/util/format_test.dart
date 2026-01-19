/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_terminal/dcli_terminal.dart';
import 'package:test/test.dart';

void main() {
  test('format humanReadable', () {
    expect(Format().bytesAsReadable(1), '    1B');
    expect(Format().bytesAsReadable(11), '   11B');
    expect(Format().bytesAsReadable(121), '  121B');

    expect(Format().bytesAsReadable(1000), ' 1000B');
    expect(Format().bytesAsReadable(1234), '1.205K');
    expect(Format().bytesAsReadable(11000), '10.74K');
    expect(Format().bytesAsReadable(121000), '118.2K');

    expect(Format().bytesAsReadable(1000000), '976.6K');
    expect(Format().bytesAsReadable(11000000), '10.49M');
    expect(Format().bytesAsReadable(121000000), '115.4M');

    expect(Format().bytesAsReadable(1000000000), '953.7M');
    expect(Format().bytesAsReadable(11000000000), '10.24G');
    expect(Format().bytesAsReadable(121000000000), '112.7G');

    expect(Format().bytesAsReadable(1000000000000), '931.3G');
    expect(Format().bytesAsReadable(11000000000000), '10.00T');
    expect(Format().bytesAsReadable(121000000000000), '110.0T');

    expect(Format().bytesAsReadable(1000000000000000), '909.5T');
    expect(Format().bytesAsReadable(11000000000000000), '1e+16');
    expect(Format().bytesAsReadable(121000000000000000), '1e+17');
  });

  test('limitString', () {
    expect(Format().limitString('0123456789', width: 11), '0123456789');
    expect(Format().limitString('0123456789', width: 10), '0123456789');
    expect(Format().limitString('0123456789', width: 9), '012...789');
    expect(Format().limitString('0123456789', width: 8), '01...89');
    expect(Format().limitString('0123456789', width: 7), '01...89');
    expect(Format().limitString('0123456789', width: 6), '0...9');
    expect(Format().limitString('0123456789', width: 5), '0...9');
    expect(Format().limitString('0123456789', width: 4), '...');
    expect(Format().limitString('0123456789', width: 3), '...');
    expect(Format().limitString('0123456789', width: 2), '.');
    expect(Format().limitString('0123456789', width: 1), '.');
  });
}
