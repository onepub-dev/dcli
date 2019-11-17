import 'dart:io';

import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  String testFile = join(TEST_ROOT, "lines.txt");

  t.group("FileSync", () {
    t.test("Append", () {
      if (exists(testFile)) {
        delete(testFile);
      }
      FileSync file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
      for (int i = 0; i < 10; i++) {
        file.append("Line ${i} is here");
      }
      file.close();

      FileStat stat = file.stat();

      t.expect(stat.size, t.equals(150));
    });
  });
}
