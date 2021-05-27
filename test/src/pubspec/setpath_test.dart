@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/pub_cache.dart';
import 'package:dcli/windows.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:win32/win32.dart';

void _appendIfAbsent(String newPath) {
  final path =
      regGetExpandString(HKEY_CURRENT_USER, 'Environment', 'Path');

  if (!path.contains(newPath)) {
    regAppendToPath(newPath);
  }
}

void main() {
  test('setPath', () {
    const dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);
    // update the windows registry so the change sticks.
    _appendIfAbsent(join(dartToolDir, 'bin'));
    _appendIfAbsent(PubCache().pathToBin);
    _appendIfAbsent(Settings().pathToDCliBin);

    // 'setx PATH "${PATH.join(Env().delimiterForPATH)}"'.run;
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    const dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    const dartToolDir = '/tools/dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);
  }, skip: !Platform.isLinux);
}
