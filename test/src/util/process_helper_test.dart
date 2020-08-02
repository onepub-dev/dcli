
@Timeout(Duration(minutes: 5))
import 'dart:io';

import 'package:dshell/dshell.dart';
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
