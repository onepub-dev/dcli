@Timeout(Duration(minutes: 5))
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('ProcessHelper', () {
    ProcessHelper().getProcessName(pid);
  });

  // test('ProcessHelper', () {
  //   TestFileSystem().withinZone((fs) async {

  //     ProcessHelper().getProcessName(pid);

  //   });
  // });
}
