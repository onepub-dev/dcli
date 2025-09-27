/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:collection/collection.dart';
import 'package:dcli/dcli.dart';
import 'package:posix/posix.dart';
import 'package:test/test.dart';

void main() {
  test('posix shell ...', () async {
    final shell = Shell.current;
    // expect(shell.isPrivilegedUser, true);

    await withTempFileAsync ((tmpGroup) async{
      // final group = name(tmpGroup);
      try {
        //'groupadd -g 21234 $group'.run;

        // use a temp file name as a temp user name
        await withTempFileAsync ((tmpUsername) async{
          // final username = name(tmpUsername);

          try {
            // 'useradd -g $group $username'.run;

            final sudoGroups = getGroups();
            print(sudoGroups);

            shell.releasePrivileges();
            final userGroups = getGroups();
            // print(userGroups);

            final eq = const ListEquality<Group>().equals;

            // print('user: ${env['USER']}');

            // print('gid:  ${getegid()} ${getgid()}');
            // print('uid:  ${geteuid()} ${getuid()}');

            // setregid(1000, 1000);
            // setreuid(1000, 1000);
            // print('gid:  ${getegid()} ${getgid()}');
            // print('uid:  ${geteuid()} ${getuid()}');

            'bash -c env'.start(
                workingDirectory: '/opt/onepub',
                runInShell: true,
                terminal: true);

            expect(eq(sudoGroups, userGroups), false);

            shell.withPrivileges(() {
              final currentGroups = getGroups();
              print(currentGroups);
              expect(sudoGroups, orderedEquals(currentGroups));
            });

            // userGroups = getGroups();
            // print(userGroups);
          } finally {
            //'userdel $username'.run;
          }
        }, create: false);
      } finally {
        //'groupdel $group'.run;
      }
    }, create: false);
  }, tags: ['privileged']);

  test('release env ...', ()  {
    final shell = Shell.current;

    expect(shell.isPrivilegedUser, isTrue);

    // 'useradd -g $group $username'.run;

    final sudoGroups = getGroups();
    print(sudoGroups);

    shell.releasePrivileges();
    final userGroups = getGroups();
    // print(userGroups);

    final eq = const ListEquality<Group>().equals;

    // print('user: ${env['USER']}');

    // print('gid:  ${getegid()} ${getgid()}');
    // print('uid:  ${geteuid()} ${getuid()}');

    // setregid(1000, 1000);
    // setreuid(1000, 1000);
    // print('gid:  ${getegid()} ${getgid()}');
    // print('uid:  ${geteuid()} ${getuid()}');

    'bash -c env'.start(
        workingDirectory: '/opt/onepub', runInShell: true, terminal: true);

    expect(eq(sudoGroups, userGroups), false);

    shell.withPrivileges(() {
      final currentGroups = getGroups();
      print(currentGroups);
      expect(sudoGroups, orderedEquals(currentGroups));
    });
  }, tags: ['privileged']);
}
