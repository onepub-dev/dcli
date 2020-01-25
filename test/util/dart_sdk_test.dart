import 'package:dshell/src/functions/which.dart';
import 'package:dshell/src/script/dart_sdk.dart';
import 'package:test/test.dart';

import 'test_fs_zone.dart';
import 'test_paths.dart';

void main() {
  TestPaths();
  
  test('Detect Dart SDK', () {
    TestZone().run(() {
      print('Dart Path: ${DartSdk().dartPath}');
      print('Dart Path: ${DartSdk().dart2NativePath}');
      print('Dart Path: ${DartSdk().pubGetPath}');
      print('Dart Path: ${DartSdk().version}');
      print('Dart Path: ${DartSdk().exePath}');

      which('dart', first: true).forEach((line) => print('which: $line'));
    });
  }, skip: false);
}
