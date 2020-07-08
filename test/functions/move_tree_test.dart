@Timeout(Duration(seconds: 600))

import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String testFile;
void main() {
  t.group('moveTree', () {
    t.test('empty target ', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*', root: from, recursive: false).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to);

        var actual = find('*', root: to, recursive: false).toList();

        t.expect(actual, t.unorderedEquals(expected));

        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - overwrite', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*', root: from, recursive: false).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to);
        moveTree(from, to, overwrite: true);

        var actual = find('*', root: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*.txt', root: from, recursive: false).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to, filter: (file) => extension(file) == '.txt');

        var actual = find('*.txt', root: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*.txt', root: from, recursive: true).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to,
            recursive: true, filter: (file) => extension(file) == '.txt');

        var actual = find('*.txt', root: to, recursive: true).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive ', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*', root: from, recursive: true).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to, recursive: true);

        var actual = find('*', root: to, recursive: true).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive- overwrite', () {
      TestFileSystem().withinZone((fs) {
        var from = join(fs.root, 'top');
        var to = join(fs.root, 'new_top');

        if (exists(to)) {
          deleteDir(to, recursive: true);
        }

        var source = find('*', root: from, recursive: true).toList();
        var expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to, recursive: true);
        moveTree(from, to, overwrite: true, recursive: true);

        var actual = find('*', root: to, recursive: true).toList();

        t.expect(actual, expected);
        t.expect(hasMoved(source), true);
      });
    });
  });
}

/// checks that the given list of files no longer exists.
bool hasMoved(List<String> files) {
  var moved = true;
  for (var file in files) {
    if (exists(file)) {
      printerr('The file $file was not moved');
      moved = false;
      break;
    }
  }
  return moved;
}

List<String> subname(List<String> expected, String from, String replace) {
  var result = <String>[];

  for (var path in expected) {
    path = path.replaceAll(from, replace);
    result.add(path);
  }
  return result;
}
