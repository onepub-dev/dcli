import 'package:dshell/src/util/progress.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.group('Find', () {
    t.test('Search for *.txt files in top directory ', () {
      TestZone().run(() {
        var paths = setup();
        var found = find('*.txt', root: paths.top, recursive: false).toList();
        found.sort();
        var expected = [join(paths.top, 'one.txt'), join(paths.top, 'two.txt')];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.jpg ', () {
      TestZone().run(() {
        var paths = setup();
        var found = find('*.jpg', root: paths.top).toList();

        find('*.jpg', root: paths.top).forEach((line) => print(line));

        find('*.jpg', progress: Progress((line) => print(line)));

        found.sort();
        var expected = [
          join(paths.top, 'one.jpg'),
          join(paths.middle, 'two.jpg'),
          join(paths.bottom, 'three.jpg')
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.txt ', () {
      TestZone().run(() {
        var paths = setup();
        var found = find('*.txt', root: paths.top).toList();

        found.sort();
        var expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt')
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });
  });
}

class Paths {
  String top;
  String middle;
  String bottom;

  Paths() {
    top = join(TEST_ROOT, 'top');
    middle = join(top, 'middle');
    bottom = join(middle, 'bottom');
  }
}

Paths setup() {
  print('PWD $pwd');

  var paths = Paths();

  // Create some the test dirs.
  if (!exists(paths.bottom)) {
    createDir(paths.bottom, recursive: true);
  }

  // Create test files

  touch(join(paths.top, 'one.txt'), create: true);
  touch(join(paths.top, 'two.txt'), create: true);
  touch(join(paths.top, 'one.jpg'), create: true);

  touch(join(paths.middle, 'three.txt'), create: true);
  touch(join(paths.middle, 'four.txt'), create: true);
  touch(join(paths.middle, 'two.jpg'), create: true);

  touch(join(paths.bottom, 'five.txt'), create: true);
  touch(join(paths.bottom, 'six.txt'), create: true);
  touch(join(paths.bottom, 'three.jpg'), create: true);

  return paths;
}
