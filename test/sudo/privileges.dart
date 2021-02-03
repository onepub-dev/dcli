#! /usr/bin/env dcli
import 'package:dcli/dcli.dart';
import 'package:posix/posix.dart';
import 'package:test/test.dart';

void main() {
  test('isPriviliged', () {
    try {
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

      if (exists('test.txt')) {
        delete('test.txt');
      }
      touch('test.txt', create: true);
      'ls -la test.txt'.run;

      print('start a non-priviledge command');

      'touch test.txt'.start(privileged: true);
      'ls -la test.txt'.run;

      Shell.current.withPrivileges(() {
        print(green('withPrivileges'));
        print('with privileges euid: ${geteuid()}');
        print('with privileges egid: ${getegid()}');

        print('start a priviledge command');

        'touch test.txt'.start(privileged: true);
        'ls -la test.txt'.run;

        if (exists('test2.txt')) {
          delete('test2.txt');
        }

        touch('test2.txt', create: true);

        'ls -la test2.txt'.run;
      });
    } on PosixException catch (e, st) {
      print(e);
      print(st);
    }
  });

  test('loggedInUsersHome ...', () async {
    final home = join(rootPath, 'home', env['SUDO_USER']);
    print('sudo logged in user home =$home');
    expect((Shell.current as PosixShell).loggedInUsersHome, home);
  });

  test('pub-cache path ...', () async {
    print(orange('pub-cache path =${PubCache().pathTo}'));
    expect(PubCache().pathTo,
        join((Shell.current as PosixShell).loggedInUsersHome, '.pub-cache'));
  });
}
