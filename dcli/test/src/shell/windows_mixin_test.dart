/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

@TestOn('windows')
library;

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:test/test.dart';
import 'package:win32/win32.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final drive = env['HOMEDRIVE'];
    final path = env['HOMEPATH'];
    final home = '$drive$path';
    expect((Shell.current as WindowsMixin).loggedInUsersHome, home);
  });

  test('isPrivileged', () {
    expect(
        Shell.current.isPrivilegedUser, Platform.isWindows ? isTrue : isFalse);
  });

  test('Add .dart Associations', () {
    const progIds = r'Software\Classes\.dart\OpenWithProgids';

    if (regKeyExists(HKEY_CURRENT_USER, progIds)) {
      regDeleteKey(HKEY_CURRENT_USER, progIds);
    }
    const command = r'Software\Classes\noojee.dcli\shell\open\command';

    if (regKeyExists(HKEY_CURRENT_USER, command)) {
      regDeleteKey(HKEY_CURRENT_USER, command);
    }

    CmdShell.withPid(pid).addFileAssociation(Settings().pathToDCliBin);

    expect(regKeyExists(HKEY_CURRENT_USER, progIds), isTrue);
    expect(regKeyExists(HKEY_CURRENT_USER, command), isTrue);
  });
}
