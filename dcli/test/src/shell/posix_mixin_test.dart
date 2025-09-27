/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

@TestOn('posix')
library;

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', ()  {
    final home = join(rootPath, 'home', env['USER']);
    expect((Shell.current as PosixShell).loggedInUsersHome, home);
  });
}
