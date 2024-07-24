@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('moveDir', () {
    t.test('empty to ', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }
        moveDir(from, to);
        t.expect(exists(to), t.equals(true));
      });
    });

    t.test('existing to ', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (!exists(from)) {
          createDir(from, recursive: true);
        }
        if (!exists(to)) {
          createDir(to, recursive: true);
        }

        t.expect(
          () => moveDir(from, to),
          throwsA(
            t.predicate<MoveDirException>(
              (e) =>
                  e.message == 'The [to] path ${truepath(to)} must NOT exist.',
            ),
          ),
        );
      });
    });

    t.test('from not a directory ', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top', 'file');
        final to = join(fsRoot, 'new_top');

        if (!exists(dirname(from))) {
          createDir(dirname(from), recursive: true);
        }
        touch(from, create: true);

        t.expect(
          () => moveDir(from, to),
          throwsA(
            t.predicate<MoveDirException>(
              (e) =>
                  e.message ==
                  'The [from] path ${truepath(from)} must be a directory.',
            ),
          ),
        );
      });
    });

    t.test('from does not exist ', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'random');
        final to = join(fsRoot, 'new_top');

        t.expect(
          () => moveDir(from, to),
          throwsA(
            t.predicate<MoveDirException>(
              (e) =>
                  e.message ==
                  'The [from] path ${truepath(from)} does not exists.',
            ),
          ),
        );
      });
    });
  });
}

// /// checks that the given list of files no longer exists.
// bool hasMoved(List<String> files) {
//   var moved = true;
//   for (final file in files) {
//     if (exists(file)) {
//       printerr('The file $file was not moved');
//       moved = false;
//       break;
//     }
//   }
//   return moved;
// }

// List<String> subname(List<String> expected, String from, String replace) {
//   final result = <String>[];

//   for (var path in expected) {
//     path = path.replaceAll(from, replace);
//     result.add(path);
//   }
//   return result;
// }
