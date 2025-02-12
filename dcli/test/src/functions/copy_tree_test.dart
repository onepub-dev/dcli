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
  t.group('copyTree', () {
    t.test('empty target ', () async {
      await withTempDirAsync((testRoot) async {
        TestFileSystem.buildDirectoryTree(testRoot);
        final from = join(testRoot, 'top');
        final to = join(testRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected =
            find('*', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);

        final actual =
            find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - overwrite', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected =
            find('*', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to);
        copyTree(from, to, overwrite: true);

        final actual =
            find('*', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - filter *.txt', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }

        var expected =
            find('*.txt', workingDirectory: from, recursive: false).toList();
        expected = subname(expected, 'top', 'new_top');
        createDir(to);
        copyTree(from, to, filter: (file) => extension(file) == '.txt');

        final actual =
            find('*.txt', workingDirectory: to, recursive: false).toList();

        t.expect(actual, unorderedEquals(expected));
      });
    });

    t.test('empty target - recursive - filter *.txt', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

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

    t.test('empty target - recursive ', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

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

    t.test('empty target - recursive- overwrite', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

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

    t.test('empty subdir - copy empty subdirectories', () async {
      await withTempDirAsync((fsRoot) async {
        TestFileSystem.buildDirectoryTree(fsRoot, includedEmptyDir: true);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

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

    t.test('do not copy empty directories when includeEmpty is false',
        () async {
      await withTempDirAsync((fsRoot) async {
        // Build a directory tree that includes an empty directory.
        TestFileSystem.buildDirectoryTree(fsRoot, includedEmptyDir: true);
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        if (exists(to)) {
          deleteDir(to);
        }
        createDir(to);

        // Copy the tree with includeEmpty set to false.
        copyTree(from, to, includeEmpty: false);

        // The empty directory "empty" should NOT be present in the destination.
        final destEmptyDir = join(to, 'empty');
        t.expect(
          exists(destEmptyDir),
          isFalse,
          reason:
              'Empty directory should not be copied when includeEmpty is false',
        );
      });
    });

    t.test('do not copy symbolic links when includeLinks is false', () async {
      await withTempDirAsync((fsRoot) async {
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        // Create the source directory and a file.
        createDir(from, recursive: true);
        final filePath = join(from, 'file.txt');
        touch(filePath, create: true);

        // Create a symbolic link in the source directory.
        final linkPath = join(from, 'link_to_file.txt');
        if (!exists(linkPath)) {
          createSymLink(targetPath: filePath, linkPath: linkPath);
        }

        createDir(to);

        // Copy the tree with includeLinks set to false.
        copyTree(from, to, includeLinks: false);

        // The symbolic link should NOT be present in the destination.
        final destLinkPath = join(to, 'link_to_file.txt');
        t.expect(
          exists(destLinkPath),
          isFalse,
          reason:
              'Symbolic link should not be copied when includeLinks is false',
        );

        // Verify that the regular file was copied.
        final destFilePath = join(to, 'file.txt');
        t.expect(
          exists(destFilePath),
          isTrue,
          reason: 'Regular file should be copied',
        );
      });
    });

    t.test('copy symbolic links when includeLinks is true', () async {
      await withTempDirAsync((fsRoot) async {
        final from = join(fsRoot, 'top');
        final to = join(fsRoot, 'new_top');

        // Create the source directory and a file.
        createDir(from, recursive: true);
        final filePath = join(from, 'file.txt');
        touch(filePath, create: true);

        // Create a symbolic link in the source directory.
        final linkPath = join(from, 'link_to_file.txt');
        if (!exists(linkPath)) {
          createSymLink(targetPath: filePath, linkPath: linkPath);
        }

        createDir(to);

        // Copy the tree with includeLinks set to true.
        copyTree(from, to);

        // The symbolic link should be processed.
        final destLinkPath = join(to, 'link_to_file.txt');
        t.expect(
          exists(destLinkPath),
          isTrue,
          reason: 'Symbolic link should be copied when includeLinks is true',
        );

        /// Mimic GNU cp behavior: a linked file is copied by dereferencing
        /// it, so the destination file is a regular file rather than a symlink.
        t.expect(
          isFile(destLinkPath),
          isTrue,
          reason: 'Copied symlink should be dereferenced to a regular file',
        );
      });
    });

    // ─── NEW TEST: Copy a symlinked directory (mimicking GNU cp) ──────────────

    t.test('copy symlinked directory mimics GNU cp behaviour', () async {
      await withTempDirAsync((fsRoot) async {
        // Set up the source directory structure.
        final top = join(fsRoot, 'top');
        createDir(top);

        // Create a real directory with a file inside.
        final realDir = join(top, 'realDir');
        createDir(realDir);
        final fileInRealDir = join(realDir, 'example.txt');
        touch(fileInRealDir, create: true);

        // Create a symlink in 'top' that points to 'realDir'.
        final linkedDir = join(top, 'linkedDir');
        if (!exists(linkedDir)) {
          createSymLink(targetPath: realDir, linkPath: linkedDir);
        }

        // Set up the destination directory.
        final newTop = join(fsRoot, 'new_top');
        createDir(newTop);

        // Copy the tree from 'top' to 'new_top'.
        copyTree(top, newTop);

        // In the destination, 'linkedDir' should now be a real directory,
        // not a symlink, with the contents of the original 'realDir'.
        final destLinkedDir = join(newTop, 'linkedDir');
        t.expect(
          exists(destLinkedDir),
          isTrue,
          reason: 'Linked directory should be copied to the destination',
        );
        t.expect(
          isDirectory(destLinkedDir),
          isTrue,
          reason: 'The copied linked directory should be a directory',
        );
        t.expect(
          isLink(destLinkedDir),
          isFalse,
          reason:
              'The linked directory should be dereferenced (not a symlink) in the copy',
        );

        // Verify that the file inside the original real directory is present.
        final destFile = join(destLinkedDir, 'example.txt');
        t.expect(
          exists(destFile),
          isTrue,
          reason: 'File inside the linked directory should be copied',
        );
      });
    });
  });
}

/// Helper function that replaces occurrences of [from] with [replace]
/// in each path in [expected].
List<String> subname(List<String?> expected, String from, String replace) {
  final result = <String>[];

  for (var path in expected) {
    path = path!.replaceAll(from, replace);
    result.add(path);
  }
  return result;
}
