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
import 'package:test/test.dart';

void main() {
  test('bash shell loggedInUser', () async {
    expect(Shell.current.loggedInUser, env['USER']);
  });

  test('isPrivilegedPasswordRequired', () {
    /// ensure the sudo password has been flushed.
    'sudo -K'.run;

    /// Force dcli to see the bash shell.
    env['SHELL'] = BashShell.shellName;

    expect(Shell.current.isPrivilegedPasswordRequired, true);
  });

  // don't know how to automat this test as we need the sudo password.
  // test('bash shell loggedInUser under sudo', () async {
  //   expect(Shell.current.loggedInUser, env['USER'));
  // });
}
