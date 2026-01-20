/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('truepath ...', () {
    expect(truepath(join(rootPath, 'tmp')), equals(absolute(rootPath, 'tmp')));
    expect(
      truepath(join(rootPath, 'tmp', '..', 'tmp')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'tmp', '..', 'tmp', '.')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'tmp', '.')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'Local')),
      equals(absolute(rootPath, 'Local')),
    );
  });

  test(
    'Posix rootPath',
    () {
      expect(rootPath, equals('/'));
    },
    skip: core.Settings().isWindows,
  );

  test(
    'Windows rootPath',
    () {
      final drive = pwd[0];
      expect(rootPath, equals('$drive:\\'));
    },
    skip: !core.Settings().isWindows,
  );
}
