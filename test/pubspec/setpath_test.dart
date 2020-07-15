import 'dart:io';
import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/pub_cache.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('setx', () {
    var dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().pathPutIfAbsent(join(dartToolDir, 'bin'));
    Env().pathPutIfAbsent(PubCache().binPath);
    Env().pathPutIfAbsent(Settings().dshellBinPath);

    print(PATH);

    'setx PATH "${PATH.join(Env().pathDelimiter)}"'.run;
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    var dartToolDir = r'C:\tools\dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().pathPutIfAbsent(join(dartToolDir, 'bin'));
    Env().pathPutIfAbsent(PubCache().binPath);
    Env().pathPutIfAbsent(Settings().dshellBinPath);

    print(PATH);
  }, skip: !Platform.isWindows);

  test('PutIfAbsent', () {
    var dartToolDir = r'/tools/dart-sdk';

    /// add the dartsdk path to the windows path.
    Env().pathPutIfAbsent(join(dartToolDir, 'bin'));
    Env().pathPutIfAbsent(PubCache().binPath);
    Env().pathPutIfAbsent(Settings().dshellBinPath);

    print(PATH);
  }, skip: !Platform.isLinux);
}
