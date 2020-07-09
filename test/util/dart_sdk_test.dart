@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/script/dart_sdk.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('Detect Dart SDK', () {
    TestFileSystem().withinZone((fs) {
      print('Dart Path: ${DartSdk().dartExePath}');
      print('Dart Path: ${DartSdk().dart2NativePath}');
      print('Dart Path: ${DartSdk().pubPath}');
      print('Dart Path: ${DartSdk().version}');

      which('dart', first: true).forEach((line) => print('which: $line'));
    });
  }, skip: false);

  test('Install Dart Sdk', () {
    TestFileSystem().withinZone((fs) {
      var defaultPath = join(fs.uniquePath, 'dart-sdk');
      var installPath = DartSdk().installFromArchive(defaultPath);
      setDartSdkPath(installPath);
      print('installed To $installPath');
      expect(exists(DartSdk().dartExePath), equals(true));
    });
  }, skip: true);
}
