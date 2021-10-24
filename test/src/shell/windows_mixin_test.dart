@TestOn('windows')
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/platform/windows/registry.dart';
import 'package:dcli/src/shell/cmd_shell.dart';
import 'package:dcli/src/shell/windows_mixin.dart';
import 'package:dcli/windows.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final drive = env['HOMEDRIVE'];
    final path = env['HOMEPATH'];
    final home = '$drive$path';
    expect((Shell.current as WindowsMixin).loggedInUsersHome, home);
  });

  test('isPrivileged', () {
    expect(Shell.current.isPrivilegedUser, isFalse);
  });

  test('Add .dart Associations', () {
    regDeleteKey(HKEY_CURRENT_USER, r'Software\Classes\.dart\OpenWithProgids');
    regDeleteKey(
        HKEY_CURRENT_USER, r'\Software\Classes\noojee.dcli\shell\open\command');

    CmdShell.withPid(pid).addFileAssociation(Settings().pathToDCliBin);
  });
}
