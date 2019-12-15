import 'dart:io';

import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group("Head", () {
    t.test("head 5", () {
      TestZone().run(() {
        String testFile = join(TEST_ROOT, "lines.txt");
        if (exists(testFile)) {
          delete(testFile);
        }
        createDir(TEST_ROOT, recursive: true);
        FileSync file = FileSync(testFile, fileMode: FileMode.write);
        for (int i = 0; i < 10; i++) {
          file.append("Line ${i} is here");
        }
        file.close();

        List<String> lines = head(testFile, 5).toList();

        t.expect(lines.length, t.equals(5));
      });
    });
  });
}
