import 'dart:io';

import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group("FileSync", () {
    t.test("Append", () {
      TestZone().run(() {
        String testFile = join(TEST_ROOT, "lines.txt");

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

    t.test("Write", () {
      TestZone().run(() {
        String testFile = join(TEST_ROOT, "lines.txt");
        if (exists(testFile)) {
          delete(testFile);
        }
        FileSync file = FileSync(testFile, fileMode: FileMode.writeOnlyAppend);
        for (int i = 0; i < 10; i++) {
          file.append("Line ${i} is here");
        }
        String replacement = "This is all that should be left";
        file.write(replacement, newline: false);
        file.close();

        FileStat stat = file.stat();

        t.expect(stat.size, t.equals(replacement.length));
      });
    });
  });
}
