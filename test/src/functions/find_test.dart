@Timeout(Duration(seconds: 600))

import 'package:dcli/src/util/progress.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Find', () {
    t.test('Search for *.txt files in top directory ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.txt', root: paths.top, recursive: false).toList();
        found.sort();
        var expected = [join(paths.top, 'one.txt'), join(paths.top, 'two.txt')];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.jpg ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.jpg', root: paths.top).toList();

        find('*.jpg', root: paths.top).forEach(print);
        t.expect(find('one.jpg', root: paths.top).toList(),
            t.equals([join(paths.top, 'one.jpg')]));

        t.expect(find('two.jpg', root: paths.top).toList(),
            t.equals([join(paths.middle, 'two.jpg')]));

        find('*.jpg', progress: Progress(print));

        found.sort();
        var expected = [
          join(paths.top, 'fred.jpg'),
          join(paths.top, 'one.jpg'),
          join(paths.middle, 'two.jpg'),
          join(paths.bottom, 'three.jpg')
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.txt ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
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

    t.test('ignore hidden files *.txt  ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.txt', root: paths.top).toList();

        found.sort();
        var expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt'),
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('find hidden files *.txt  ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found =
            find('*.txt', root: paths.top, includeHidden: true).toList();

        found.sort();
        var expected = [
          join(paths.thidden, 'fred.txt'),
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.top, '.two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.middle, '.four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt'),
          join(paths.hidden, 'seven.txt'),
          join(paths.hidden, '.seven.txt'),
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });
  });
}
