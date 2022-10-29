/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:collection/collection.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:posix/posix.dart';
import 'package:test/test.dart';

void main() {
  test('posix shell ...', () async {
    final shell = Shell.current;
    // expect(shell.isPrivilegedUser, true);

    withTempFile((tmpGroup) {
      // final group = name(tmpGroup);
      try {
        //'groupadd -g 21234 $group'.run;

        // use a temp file name as a temp user name
        withTempFile((tmpUsername) {
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

  test('release env ...', () async {
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

String name(String fileBasedName) =>
    basenameWithoutExtension(fileBasedName).replaceAll('-', '');
