/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:posix/posix.dart';
import 'package:test/test.dart';

void main() {
  /// This test need to be run under sudo
  test(
    'isPrivligedUser',
    () {
      // Settings().setVerbose(enabled: true);
      expect(Shell.current.isPrivilegedUser, isTrue);
      Shell.current.releasePrivileges();
      expect(Shell.current.isPrivilegedUser, isFalse);
      Shell.current.restorePrivileges();
      expect(Shell.current.isPrivilegedUser, isTrue);
    },
    skip: !Shell.current.isPrivilegedUser,
    tags: [
      'privileged',
    ],
  );

  test(
    'EUID',
    () {
      final ruid = getuid();
      expect(ruid == 0, isTrue);
      expect(Shell.current.isPrivilegedUser, isTrue);
      expect(geteuid(), equals(0));
      Shell.current.releasePrivileges();
      expect(Shell.current.isPrivilegedUser, isFalse);
      expect(geteuid() != ruid, isTrue);
      Shell.current.restorePrivileges();
      expect(Shell.current.isPrivilegedUser, isTrue);
      expect(geteuid(), equals(0));
    },
    skip: !Shell.current.isPrivilegedUser,
    tags: [
      'privileged',
    ],
  );

  /// we touch all of the dart files but don't change their ownership.
  // find('*.dart', root: '.').forEach((file) {
  //   print('touching $file');
  //   copy(file, '$file.bak', overwrite: true);
  // });

  // if (exists('/tmp/test')) {
  //   deleteDir('/tmp/test');
  // }
  // createDir('/tmp/test');
  // // do something terrible by temporary regaining the privileges.
  // withPrivileges(() {
  //   print('copy stuff I should not.');
  //   copyTree('/etc/', '/tmp/test');
  // });
}

// void privileged({required bool enabled}) {
//   /// how do I changed from root back to the normal user.
//   if (enabled) {
//     print('Enabled root priviliges');
//   } else {
//     print('Disabled root priviliges');
//   }
// }

// void withPrivileges(void Function() action) {
//   privileged(enabled: true);
//   action();
//   privileged(enabled: false);
// }
