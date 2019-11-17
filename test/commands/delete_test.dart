import 'dart:io';

import 'package:dshell/util/file_sync.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  String testFile = join(TEST_ROOT, "lines.txt");

  t.group("Delete", () {
    t.test("delete ", () {
      touch(testFile, create: true);

      delete(testFile);
      t.expect(!exists(testFile), t.equals(true));
    });

    t.test("delete non-existing ", () {
      touch(testFile, create: true);
      delete(testFile);

      t.expect(
          () => delete(testFile), t.throwsA(t.TypeMatcher<DeleteException>()));
    });
  });
}
