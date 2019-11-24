import 'dart:io';

import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  String testFile = join(TEST_ROOT, "lines.txt");

  t.group("Head", () {
    t.test("head 5", () {
      if (exists(testFile)) {
        delete(testFile);
      }
      createDir(TEST_ROOT, createParent: true);
      FileSync file = FileSync(testFile, fileMode: FileMode.write);
      for (int i = 0; i < 10; i++) {
        file.append("Line ${i} is here");
      }
      file.close();

      List<String> lines = head(testFile, 5).toList();

      t.expect(lines.length, t.equals(5));
    });
  });
}
