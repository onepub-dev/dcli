@Timeout(Duration(seconds: 600))

import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String testFile;
void main() {
  t.group('copyTree', () {
    t.test('empty target ', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*', root: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);

        var actual = find('*', root: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - overwrite', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*', root: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);
        copyTree(from, to, overwrite: true);

        var actual = find('*', root: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*.txt', root: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, filter: (file) => extension(file) == '.txt');

        var actual = find('*.txt', root: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*.txt', root: from, recursive: true).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to,
            recursive: true, filter: (file) => extension(file) == '.txt');

        var actual = find('*.txt', root: to, recursive: true).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive ', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*', root: from, recursive: true).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, recursive: true);

        var actual = find('*', root: to, recursive: true).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive- overwrite', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var expected = find('*', root: from, recursive: true).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, recursive: true);
        copyTree(from, to, overwrite: true, recursive: true);

        var actual = find('*', root: to, recursive: true).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });
  });
}

List<String> subname(List<String> expected, String from, String replace) {
  var result = <String>[];

  for (var path in expected) {
    path = path.replaceAll(from, replace);
    result.add(path);
  }
  return result;
}
