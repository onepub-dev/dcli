/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CopyException)
/// @Throwing(CopyTreeException)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(TouchException)
void main() {
  test('copy filename to filename the good path', () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    copy(from, to);

    expect(exists(from), isTrue);

    expect(exists(to), isTrue);

    final toContent = read(to).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test('copy filename to directory -  the good path', () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    final to = join(root, 'to');
    final toFilename = join(root, fromFilename);
    createDir(to, recursive: true);

    copy(from, to);

    expect(exists(from), isTrue);

    expect(exists(toFilename), isTrue);

    final toContent = read(toFilename).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test("copy filename -  from doesn't exist", () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename);

    final to = join(root, 'to');
    createDir(to, recursive: true);

    expect(
      () => copy(from, to),
      throwsA(
        predicate(
          (e) =>
              e is CopyException &&
              e.message == "The 'from' file ${truepath(from)} does not exists.",
        ),
      ),
    );
  });

  test('copy filename -  to already exists', () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    touch(to, create: true);

    expect(
      () => copy(from, to),
      throwsA(
        predicate(
          (e) =>
              e is CopyException &&
              e.message == 'The target file ${truepath(to)} already exists.',
        ),
      ),
    );
  });

  test('copy with overwrite', () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, toFilename);

    /// the 'to' file aready exists
    touch(to, create: true);

    expect(exists(to), isTrue);

    copy(from, to, overwrite: true);

    expect(exists(from), isTrue);

    expect(exists(to), isTrue);

    final toContent = read(to).toParagraph();
    final fromContent = read(from).toParagraph();

    expect(fromContent, equals(toContent));
  });

  test("copy to filename -  to directory doesn't exist", () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    const toFilename = 'text2.txt';
    final to = join(root, 'new', toFilename);

    expect(
      () => copy(from, to),
      throwsA(
        predicate((e) =>
            e is CopyException &&
            e.message ==
                "The 'to' directory ${truepath(dirname(to))} does not exists."),
      ),
    );
  });

  test("copy to directory -  to directory doesn't exist", () {
    final root = createTempDir();

    const fromFilename = 'text.txt';
    final from = join(root, fromFilename)..append('Hellow World');

    final to = join(root, 'new', 'new');

    expect(
      () => copy(from, to),
      throwsA(
        predicate((e) =>
            e is CopyException &&
            e.message ==
                "The 'to' directory ${truepath(dirname(to))} does not exists."),
      ),
    );
  });

  test('copy symlink', () async {
    /// path of test symlink that exists as part of test package.
    await withTempDirAsync((testDir) async {
      final pathToTestFiles = join('test', 'test_files');

      copyTree(pathToTestFiles, testDir);
      final pathToTestMd = join(testDir, 'target.md');
      final pathToLink = join(testDir, 'link_to_target.md');
      createSymLink(targetPath: pathToTestMd, linkPath: pathToLink);

      final pathToCopyOfLink = join(testDir, 'copy_of_link.md');
      if (exists(pathToCopyOfLink)) {
        delete(pathToCopyOfLink);
      }

      copy(pathToLink, pathToCopyOfLink);
      expect(exists(pathToCopyOfLink, followLinks: false), isTrue);
      expect(
          exists(
            pathToCopyOfLink,
          ),
          isTrue);
      expect(isFile(pathToCopyOfLink), isTrue);
      expect(isLink(pathToCopyOfLink), isFalse);

      expect(exists(pathToLink, followLinks: false), isTrue);
      expect(
          exists(
            pathToLink,
          ),
          isTrue);
      expect(isLink(pathToLink), isTrue);
    });
  });
}
