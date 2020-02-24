@Timeout(Duration(seconds: 600))
import 'package:dshell/src/functions/which.dart';
import 'package:dshell/src/script/dart_sdk.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('Detect Dart SDK', () {
    TestFileSystem().withinZone((fs) {
      print('Dart Path: ${DartSdk().dartExePath}');
      print('Dart Path: ${DartSdk().dart2NativePath}');
      print('Dart Path: ${DartSdk().pubGetPath}');
      print('Dart Path: ${DartSdk().version}');

      which('dart', first: true).forEach((line) => print('which: $line'));
    });
  }, skip: false);
}
