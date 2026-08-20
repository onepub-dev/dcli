/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/shell/posix_shell.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:posix/posix.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(PosixException)
/// @Throwing(TouchException)
void main() {
  test('pre-sudo environment derives the Linux user session', () {
    if (!Platform.isLinux) {
      return;
    }

    core.withEnvironment(
      () {
        final user = UserEnvironment.preSudo(pathToHome: '/home/test-user');

        expect(user.pathToXdgRuntimeDirectory, '/run/user/1234');
        expect(user.dbusSessionBusAddress, 'unix:path=/run/user/1234/bus');
      },
      environment: {
        'SUDO_UID': '1234',
        'SUDO_GID': '1234',
        'SUDO_USER': 'test-user',
        'XDG_RUNTIME_DIR': '',
        'DBUS_SESSION_BUS_ADDRESS': '',
      },
    );
  });

  test('pre-sudo environment preserves an explicit user session', () {
    if (!Platform.isLinux) {
      return;
    }

    core.withEnvironment(
      () {
        final user = UserEnvironment.preSudo(pathToHome: '/home/test-user');

        expect(user.pathToXdgRuntimeDirectory, '/custom/runtime');
        expect(user.dbusSessionBusAddress, 'unix:abstract=custom-session');
      },
      environment: {
        'SUDO_UID': '1234',
        'SUDO_GID': '1234',
        'SUDO_USER': 'test-user',
        'XDG_RUNTIME_DIR': '/custom/runtime',
        'DBUS_SESSION_BUS_ADDRESS': 'unix:abstract=custom-session',
      },
    );
  });

  test('pre-sudo environment replaces an inherited root session', () {
    if (!Platform.isLinux) {
      return;
    }

    core.withEnvironment(
      () {
        final user = UserEnvironment.preSudo(pathToHome: '/home/test-user');

        expect(user.pathToXdgRuntimeDirectory, '/run/user/1234');
        expect(user.dbusSessionBusAddress, 'unix:path=/run/user/1234/bus');
      },
      environment: {
        'SUDO_UID': '1234',
        'SUDO_GID': '1234',
        'SUDO_USER': 'test-user',
        'XDG_RUNTIME_DIR': '/run/user/0',
        'DBUS_SESSION_BUS_ADDRESS': 'unix:path=/run/user/0/bus',
      },
    );
  });

  test(
    'posix shell ...',
    () async {
      final shell = Shell.current;
      // expect(shell.isPrivilegedUser, true);

      await withTempFileAsync((tmpGroup) async {
        // final group = name(tmpGroup);
        try {
          //'groupadd -g 21234 $group'.run;

          // use a temp file name as a temp user name
          await withTempFileAsync((tmpUsername) async {
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
                terminal: true,
              );

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
    },
    tags: ['privileged'],
    skip: Settings().isWindows || !Shell.current.isPrivilegedUser,
  );

  test(
    'release env ...',
    () {
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
        workingDirectory: '/opt/onepub',
        runInShell: true,
        terminal: true,
      );

      expect(eq(sudoGroups, userGroups), false);

      shell.withPrivileges(() {
        final currentGroups = getGroups();
        print(currentGroups);
        expect(sudoGroups, orderedEquals(currentGroups));
      });
    },
    tags: ['privileged'],
    skip: Settings().isWindows || !Shell.current.isPrivilegedUser,
  );
}
