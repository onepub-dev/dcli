#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */




import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:posix/posix.dart';
import 'package:test/test.dart';

void main() {
  test(
    'isPrivileged',
    () {
      if (!Shell.current.isPrivilegedUser) {
        printerr(red('You must run this script with sudo.'));
        printerr(
          orange(
            'To run this script with sudo you will first need to compile it.',
          ),
        );
      }

      try {
        expect(Shell.current.isPrivilegedUser, isTrue);
        Settings().setVerbose(enabled: true);
        print('isPriviliged: ${Shell.current.isPrivilegedUser}');

        print('uid: ${getuid()}');
        print('gid: ${getgid()}');
        print('euid: ${geteuid()}');
        print('euid: ${geteuid()}');
        print('user: ${getlogin()}');
        print('SUDO_UID: ${env['SUDO_UID']}');
        print('SUDO_USER: ${env['SUDO_USER']}');
        print('SUDO_GUID: ${env['SUDO_GID']}');

        print('pre-descalation euid: ${geteuid()}');
        print('pre-descalation user egid: ${getegid()}');

        Shell.current.releasePrivileges();

        print('post-descalation euid: ${geteuid()}');
        print('post-descalation user egid: ${getegid()}');

        withTempDir((testRoot) {
          final testFile = join(testRoot, 'test.txt');
          touch(testFile, create: true);
          'ls -la $testFile'.run;

          print('start a non-priviledge command');

          'touch $testFile'.start(privileged: true);
          'ls -la $testFile'.run;

          Shell.current.withPrivileges(() {
            print(green('withPrivileges'));
            print('with privileges euid: ${geteuid()}');
            print('with privileges egid: ${getegid()}');

            print('start a priviledge command');

            'touch $testFile'.start(privileged: true);
            'ls -la $testFile'.run;

            final testFile2 = join(testRoot, 'test2.txt');

            touch(testFile2, create: true);

            'ls -la $testFile2'.run;
          });
        });

        Shell.current.restorePrivileges();
      } on PosixException catch (e, st) {
        print(e);
        print(st);
      }
    },
    tags: ['sudo'],
    skip: core.Settings().isWindows,
  );

  test('withPriviliges - allowUnpriviliged', () {
    expect(() => Shell.current.withPrivileges(() {}),
        throwsA(isA<ShellException>()));

    try {
      Shell.current.withPrivileges(() {}, allowUnprivileged: true);
    } on ShellException catch (_) {
      // we should never end up here.
      expect(true, isFalse);
    }
  }, skip: core.Settings().isWindows);

  test(
    'loggedInUsersHome ...',
    () async {
      final home = join(rootPath, 'home', env['SUDO_USER']);
      print('sudo logged in user home =$home');
      expect((Shell.current as PosixShell).loggedInUsersHome, home);
    },
    tags: ['sudo'],
    skip: core.Settings().isWindows,
  );

  test(
    'pub-cache path ...',
    () async {
      print(orange('pub-cache path =${PubCache().pathTo}'));
      expect(
        PubCache().pathTo,
        join((Shell.current as PosixShell).loggedInUsersHome, '.pub-cache'),
      );
    },
    tags: ['sudo'],
    skip: core.Settings().isWindows,
  );
}
