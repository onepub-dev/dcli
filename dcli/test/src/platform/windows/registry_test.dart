@Timeout(Duration(minutes: 5))
@TestOn('windows')
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/windows.dart';
import 'package:test/test.dart';
import 'package:win32/win32.dart';

/// @Throwing(ArgumentError)
void main() {
  late String testKey;
  var sequence = 0;
  setUp(() {
    testKey =
        'DCLITestArea-$pid-'
        '${DateTime.now().microsecondsSinceEpoch}-${sequence++}';
    regCreateKey(HKEY_CURRENT_USER, testKey);
    addTearDown(() {
      regDeleteKey(HKEY_CURRENT_USER, testKey);
      expect(regKeyExists(HKEY_CURRENT_USER, testKey), isFalse);
    });
  });

  test('windows mixin ...', () {
    regSetString(HKEY_CURRENT_USER, testKey, 'PATH_TEST', 'HI');

    final paths = regGetString(HKEY_CURRENT_USER, testKey, 'PATH_TEST');
    expect(paths, equals('HI'));
    regDeleteValue(HKEY_CURRENT_USER, testKey, 'PATH_TEST');
  });

  test('set/get dword', () {
    regSetDWORD(HKEY_CURRENT_USER, testKey, 'count', 5);
    expect(regGetDWORD(HKEY_CURRENT_USER, testKey, 'count'), equals(5));
  });

  test('devmode reads the existing setting without changing it', () {
    const key = r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock';
    const value = 'AllowDevelopmentWithoutDevLicense';
    final shell = PowerShell.withPid(pid);
    try {
      final current = regGetDWORD(HKEY_LOCAL_MACHINE, key, value);
      expect(shell.inDeveloperMode(), current == 1);
    } on WindowsException catch (error) {
      if (error.hr != hrFileNotFound) {
        rethrow;
      }
      expect(shell.inDeveloperMode, throwsA(isA<WindowsException>()));
    }
  });

  test('set/get string', () {
    regSetString(HKEY_CURRENT_USER, testKey, 'TEST_KEY', 'Hellow World');
    expect(
      regGetString(HKEY_CURRENT_USER, testKey, 'TEST_KEY'),
      equals('Hellow World'),
    );

    regDeleteValue(HKEY_CURRENT_USER, testKey, 'TEST_KEY');
  });

  test('set/get expanding string', () {
    regSetString(HKEY_CURRENT_USER, testKey, 'TEST_KEY', 'Hellow World');
    regSetExpandString(
      HKEY_CURRENT_USER,
      testKey,
      'TEST_KEY2',
      '%USERPROFILE%2',
    );

    final testKey2 = regGetExpandString(
      HKEY_CURRENT_USER,
      testKey,
      'TEST_KEY2',
    );
    expect(testKey2, equals('${Platform.environment['USERPROFILE']}2'));

    expect(
      regGetExpandString(
        HKEY_CURRENT_USER,
        testKey,
        'TEST_KEY2',
        expand: false,
      ),
      equals('%USERPROFILE%2'),
    );
    regDeleteValue(HKEY_CURRENT_USER, testKey, 'TEST_KEY2');
  });
}
