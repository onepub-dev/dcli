@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import 'package:test/test.dart' as t;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String? testFile;
void main() {
  t.group('moveTree', () {
    t.test('empty target ', () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source =
            find('*', workingDirectory: from, recursive: false).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);

        moveTree(from, to);
        print('moveTree done');

        final actual =
            find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, t.unorderedEquals(expected));

        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - overwrite', () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source =
            find('*', workingDirectory: from, recursive: false).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to);
        moveTree(from, to, overwrite: true);

        final actual =
            find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - filter *.txt', () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source =
            find('*.txt', workingDirectory: from, recursive: false).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to, filter: (file) => extension(file) == '.txt');

        final actual =
            find('*.txt', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive - filter *.txt', () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source = find('*.txt', workingDirectory: from).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to, filter: (file) => extension(file) == '.txt');

        final actual = find('*.txt', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive ', () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source = find('*', workingDirectory: from).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to);

        final actual = find('*', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });

    t.test('empty target - recursive- overwrite', () {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        final source = find('*', workingDirectory: from).toList();
        final expected = subname(source, 'top', 'new_top');
        createDir(to);
        moveTree(from, to);
        moveTree(from, to, overwrite: true);

        final actual = find('*', workingDirectory: to).toList();

        t.expect(actual, unorderedEquals(expected));
        t.expect(hasMoved(source), true);
      });
    });
  });
}

/// checks that the given list of files no longer exists.
bool hasMoved(List<String> files) {
  var moved = true;
  for (final file in files) {
    if (exists(file)) {
      printerr('The file $file was not moved');
      moved = false;
      break;
    }
  }
  return moved;
}

List<String> subname(List<String?> expected, String from, String replace) {
  final result = <String>[];

  for (var path in expected) {
    path = path!.replaceAll(from, replace);
    result.add(path);
  }
  return result;
}
