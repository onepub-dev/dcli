/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(TouchException)
void main() {
  test('chown ...', () async {
    await withTempFileAsync((test) async {
      final user = Shell.current.loggedInUser;

      chown(test, group: user, user: user);
    });
  },
      tags: ['privileged'],
      skip: Settings().isWindows || !Shell.current.isPrivilegedUser);
}
