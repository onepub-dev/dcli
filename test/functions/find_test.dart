import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  t.group("Find", () {
    print("PWD $pwd");

    String top = join(TEST_ROOT, "top");
    String middle = join(top, "middle");
    String bottom = join(middle, "bottom");

    // Create some the test dirs.
    createDir(bottom, createParent: true);

    // Create test files

    touch(join(top, "one.txt"), create: true);
    touch(join(top, "two.txt"), create: true);
    touch(join(top, "one.jpg"), create: true);

    touch(join(middle, "three.txt"), create: true);
    touch(join(middle, "four.txt"), create: true);
    touch(join(middle, "two.jpg"), create: true);

    touch(join(bottom, "five.txt"), create: true);
    touch(join(bottom, "six.txt"), create: true);
    touch(join(bottom, "three.jpg"), create: true);

    t.test("Search for *.txt files in top directory ", () {
      List<String> found = find("*.txt", root: top, recursive: false).toList();
      found.sort();
      List<String> expected = [join(top, "one.txt"), join(top, "two.txt")];
      expected.sort();
      t.expect(found, t.equals(expected));
    });

    t.test("Search recursive for *.jpg ", () {
      List<String> found = find("*.jpg", root: top).toList();

      find("*.jpg", root: top).forEach((line) => print(line));

      find('*.jpg', forEach: ForEach((line) => print(line)));
      find('*.jpg', progressive: ForEach((line) => print(line)));
      find('*.jpg', progress: ForEach((line) => print(line)));

      found.sort();
      List<String> expected = [
        join(top, "one.jpg"),
        join(middle, "two.jpg"),
        join(bottom, "three.jpg")
      ];
      expected.sort();
      t.expect(found, t.equals(expected));
    });

    t.test("Search recursive for *.txt ", () {
      List<String> found = find("*.txt", root: top).toList();

      found.sort();
      List<String> expected = [
        join(top, "one.txt"),
        join(top, "two.txt"),
        join(middle, "three.txt"),
        join(middle, "four.txt"),
        join(bottom, "five.txt"),
        join(bottom, "six.txt")
      ];
      expected.sort();
      t.expect(found, t.equals(expected));
    });
  });
}
