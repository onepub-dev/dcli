import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group("StringAsProcess", () {
    t.test("Run", () {
      TestZone().run(() {
        var testFile = "test.text";

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test("forEach", () {
      TestZone().run(() {
        List<String> lines = List();

        String linesFile = setup();

        print("pwd: " + pwd);

        assert(exists(linesFile));

        'tail -n 5 $linesFile'.forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });
    });
/*
    t.test("Pipe operator", () {
      'head -n 5 ../data/lines.txt' | 'tail -n 1'.run;
      t.expect(lines.length, t.equals(1));
    });
    */

    t.test("Lines", () {
      TestZone().run(() {
        String path = "/tmp/log/syslog";

        if (exists(path)) {
          deleteDir(dirname(path), recursive: true);
        }
        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (int i = 0; i < 10; i++) {
          path.append("head $i");
        }
        List<String> lines = 'head -n 5 $path'.toList();
        t.expect(lines.length, t.equals(5));
      });
    });
  });
}

String setup() {
  String linesFile = join(TEST_ROOT, TEST_LINES_FILE);

  if (exists(TEST_ROOT)) {
    deleteDir(TEST_ROOT, recursive: true);
  }

  createDir(TEST_ROOT);

  FileSync file = FileSync(linesFile);
  for (int i = 0; i < 10; i++) {
    file.append("Line $i");
  }
  return linesFile;
}
