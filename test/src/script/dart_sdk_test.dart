@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/dart_sdk.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Detect Dart SDK', () {
    TestFileSystem().withinZone((fs) {
      print('Dart pathToDartExe: ${DartSdk().pathToDartExe}');
      print('Dart pathToDartToNativeExe: ${DartSdk().pathToDartToNativeExe}');
      print('Dart pathToPubExe: ${DartSdk().pathToPubExe}');
      print('Dart Version: ${DartSdk().version}');
      print('Dart Major: ${DartSdk().versionMajor}');
      print('Dart Minor: ${DartSdk().versionMinor}');

      which('dart').paths.forEach((line) => print('which: $line'));
    });
  }, skip: false);

  test('Install Dart Sdk', () {
    TestFileSystem().withinZone((fs) {
      final defaultPath = join(fs.uniquePath, 'dart-sdk');
      final installPath = DartSdk().installFromArchive(defaultPath);
      setPathToDartSdk(installPath);
      print('installed To $installPath');
     expect(
          DartSdk().pathToDartExe != null && exists(DartSdk().pathToDartExe!),
          equals(true));
    });
  }, skip: true);

  test('Parse sdk version', () {
    final output = '${DartSdk().pathToDartExe} --version'.firstLine;

    expect(output, contains('Dart'));

    final version = DartSdk().version;

    expect(output, contains(version));

    expect(version, isNot(equals(null)));
  });
}
