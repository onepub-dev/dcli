@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/dart_sdk.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Detect Dart SDK', () {
    TestFileSystem().withinZone((fs) {
      print('Dart Path: ${DartSdk().pathToDartExe}');
      print('Dart Path: ${DartSdk().pathToDartToNativeExe}');
      print('Dart Path: ${DartSdk().pathToPubExe}');
      print('Dart Path: ${DartSdk().version}');

      which('dart', first: true).paths.forEach((line) => print('which: $line'));
    });
  }, skip: false);

  test('Install Dart Sdk', () {
    TestFileSystem().withinZone((fs) {
      var defaultPath = join(fs.uniquePath, 'dart-sdk');
      var installPath = DartSdk().installFromArchive(defaultPath);
      setPathToDartSdk(installPath);
      print('installed To $installPath');
      expect(exists(DartSdk().pathToDartExe), equals(true));
    });
  }, skip: true);

  test('Parse sdk version', () {
    var output = '${DartSdk().pathToDartExe} --version'.firstLine;

    expect(output, contains('Dart'));

    var version = DartSdk().version;

    expect(output, contains(version));

    expect(version, isNot(equals(null)));
  });
}
