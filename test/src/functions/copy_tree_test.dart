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
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);

        final actual = find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - overwrite', () {
      TestFileSystem().withinZone((fs) {
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);
        copyTree(from, to, overwrite: true);

        final actual = find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*.txt', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, filter: (file) => extension(file) == '.txt');

        final actual = find('*.txt', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive - filter *.txt', () {
      TestFileSystem().withinZone((fs) {
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*.txt', workingDirectory: from).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, filter: (file) => extension(file) == '.txt');

        final actual = find('*.txt', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive ', () {
      TestFileSystem().withinZone((fs) {
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*', workingDirectory: from).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);

        final actual = find('*', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive- overwrite', () {
      TestFileSystem().withinZone((fs) {
        final from = join(fs.fsRoot, 'top');
        final to = join(fs.fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected = find('*', workingDirectory: from).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);
        copyTree(from, to, overwrite: true);

        final actual = find('*', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });
  });
}

List<String> subname(List<String> expected, String from, String replace) {
  final result = <String>[];

  for (var path in expected) {
    path = path.replaceAll(from, replace);
    result.add(path);
  }
  return result;
}
