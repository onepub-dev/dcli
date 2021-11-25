@Timeout(Duration(minutes: 5))
@TestOn('windows')
import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/windows.dart';
import 'package:test/test.dart';

void main() {
  test('windows mixin ...', () async {
    regSetString(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST', 'HI');

    final paths = regGetString(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST');
    expect(paths, equals('HI'));
    regDeleteValue(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST');
  });

  test('set/get dword', () {
    regSetDWORD(HKEY_CURRENT_USER, 'DCLITestArea', 'count', 5);

    final value = regGetDWORD(HKEY_CURRENT_USER, 'DCLITestArea', 'count');

    expect(value, equals(5));

    regDeleteValue(HKEY_CURRENT_USER, 'DCLITestArea', 'count');
  });

  test(
    'devmode',
    () {
      expect(Shell.current.isPrivilegedUser, isTrue);

      if (Shell.current.isPrivilegedUser) {
        var original = 0;

        try {
          original = regGetDWORD(
            HKEY_LOCAL_MACHINE,
            r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
            'AllowDevelopmentWithoutDevLicense',
          );
        } on WindowsException catch (e) {
          if (e.hr != hrFileNotFound) {
            rethrow;
          }
        }

        regSetDWORD(
          HKEY_LOCAL_MACHINE,
          r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
          'AllowDevelopmentWithoutDevLicense',
          1,
        );

        final shell = PowerShell.withPid(pid);
        expect(shell.inDeveloperMode(), true);

        regSetDWORD(
          HKEY_LOCAL_MACHINE,
          r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
          'AllowDevelopmentWithoutDevLicense',
          0,
        );

        expect(shell.inDeveloperMode(), false);

        regSetDWORD(
          HKEY_LOCAL_MACHINE,
          r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
          'AllowDevelopmentWithoutDevLicense',
          original,
        );
      }
    },
    tags: ['privileged'],
  );

  // test('set/get lsit', (){
  //   setRegistryList(HKEY_CURRENT_USER, subKey, valueName, value)
  // })

  test('set/get string', () {
    regSetString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY', 'Hellow World');
    expect(
      regGetString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY'),
      equals('Hellow World'),
    );

    regDeleteValue(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY');
  });

  test('set/get expanding string', () {
    regSetString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY', 'Hellow World');
    regSetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'TEST_KEY2',
      '%USERPROFILE%2',
    );

    final testKey2 =
        regGetExpandString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY2');
    expect(testKey2, startsWith('C:'));
    expect(testKey2, endsWith('2'));

    expect(
      regGetExpandString(
        HKEY_CURRENT_USER,
        'Environment',
        'TEST_KEY2',
        expand: false,
      ),
      equals('%USERPROFILE%2'),
    );
    regDeleteValue(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY2');
  });

  test('append/replace  path', () {
    const testDir = 'TestDirB';
    final testPath = join(rootPath, 'TestDirB');
    final original = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// Test appending a path
    regAppendToPath(testPath);
    final withPath = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );
    expect(withPath, equals('$original;$testPath'));

    /// test append of existing path doesn't change path
    regAppendToPath(testPath);
    final doubleAppend = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// double append should not chnage path
    expect(withPath, equals(doubleAppend));

    /// test different paths which are cannonically the same
    regAppendToPath(join(testPath, '..', testDir));
    final cannonicalAppend = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// double append should not chnage path
    expect(withPath, equals(cannonicalAppend));

    /// restore the original path
    regReplacePath(original.split(';'));
    final replaced = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );
    expect(replaced, equals(original));
  });

  test('prepend  path', () {
    const testDir = 'TestDirB';
    final testPath = join(rootPath, 'TestDirB');
    final original = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// Test prepending a path
    regPrependToPath(testPath);
    final withPath = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );
    expect(withPath, equals('$testPath;$original'));

    /// test preppend of existing path doesn't change path
    regPrependToPath(testPath);
    final doublePrepend = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// double prepend should not chnage path
    expect(withPath, equals(doublePrepend));

    /// test different paths which are cannonically the same
    regPrependToPath(join(testPath, '..', testDir));
    final cannonicalPrepend = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );

    /// double prepend should not chnage path
    expect(withPath, equals(cannonicalPrepend));

    /// restore the original path
    regReplacePath(original.split(';'));
    final replaced = regGetExpandString(
      HKEY_CURRENT_USER,
      'Environment',
      'Path',
      expand: false,
    );
    expect(replaced, equals(original));
  });
}
