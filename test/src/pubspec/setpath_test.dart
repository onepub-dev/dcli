@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/pub_cache.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('setx', () {
    var dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);

    'setx PATH "${PATH.join(Env().delimiterForPATH)}"'.run;
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    var dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    var dartToolDir = r'/tools/dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().addToPATHIfAbsent(join(dartToolDir, 'bin'));
    Env().addToPATHIfAbsent(PubCache().pathToBin);
    Env().addToPATHIfAbsent(Settings().pathToDCliBin);

    print(PATH);
  }, skip: !Platform.isLinux);
}
