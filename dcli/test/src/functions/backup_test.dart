@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_common/dcli_common.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('backup/restore good path', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);
    final backupDir = join(root, '.bak');

    const content = 'Hellow World';
    file.write(content);

    backupFile(file);

    final backupFilename = '${join(backupDir, filename)}.bak';

    expect(exists(backupFilename), isTrue);
    expect(exists(file), isTrue);

    const secondline = 'Foo was here';

    file.append(secondline);

    expect(read(file).toParagraph().contains(secondline), isTrue);

    restoreFile(file);

    expect(read(file).toParagraph().contains(secondline), isFalse);

    expect(exists(backupFilename), isFalse);

    /// check .bak directory removed
    expect(exists(backupDir), isFalse);
  });

  test('restore missing backup', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    backupFile(file);

    final backupFilename = '${join(root, '.bak', filename)}.bak';

    // do a bad thing, delete the backup.
    delete(backupFilename);

    expect(() => restoreFile(file), throwsA(isA<RestoreFileException>()));
  });

  test('backup missing file', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    delete(file);

    expect(() => backupFile(file), throwsA(isA<BackupFileException>()));
  });

  test('Existing .bak directory', () async {
    final root = createTempDir();
    const filename = 'test.txt';
    final file = join(root, filename);

    const content = 'Hellow World';
    file.write(content);

    final backupPath = join(root, '.bak');
    createDir(backupPath);

    backupFile(file);

    final backupFilename = '${join(backupPath, filename)}.bak';

    expect(exists(backupFilename), isTrue);
    expect(exists(file), isTrue);

    const secondline = 'Foo was here';

    file.append(secondline);

    expect(read(file).toParagraph().contains(secondline), isTrue);

    restoreFile(file);

    expect(read(file).toParagraph().contains(secondline), isFalse);

    expect(exists(backupFilename), isFalse);
  });

  group('withFileProtection', () {
    test('single file absolute path that we delete', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        withFileProtection([tree.bottomFiveTxt], () {
          delete(tree.bottomFiveTxt);
        });
        expect(exists(tree.bottomFiveTxt), isTrue);
      });
    });

    test('single file absolute path that we modify', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        final pre = calculateHash(tree.bottomFiveTxt);

        withFileProtection([tree.bottomFiveTxt], () {
          final pre = calculateHash(tree.bottomFiveTxt);
          tree.bottomFiveTxt.append('some dummy data');
          final post = calculateHash(tree.bottomFiveTxt);
          expect(pre, isNot(equals(post)));
        });
        expect(exists(tree.bottomFiveTxt), isTrue);
        final post = calculateHash(tree.bottomFiveTxt);
        expect(pre, equals(post));
      });
    });

    test('single file relative path that we delete', () {
      final localDir = join(pwd, '.testing');
      final tree = TestDirectoryTree(localDir);

      withFileProtection([relative(tree.bottomFiveTxt)], () {
        delete(tree.bottomFiveTxt);
      });
      expect(exists(tree.bottomFiveTxt), isTrue);

      deleteDir(localDir);
    });

    test('single file relative path that we modify', () {
      final localDir = join(pwd, '.testing');
      final tree = TestDirectoryTree(localDir);

      final pre = calculateHash(tree.bottomFiveTxt);

      withFileProtection([relative(tree.bottomFiveTxt)], () {
        final pre = calculateHash(tree.bottomFiveTxt);
        tree.bottomFiveTxt.append('some dummy data');
        final post = calculateHash(tree.bottomFiveTxt);
        expect(pre, isNot(equals(post)));
      });
      expect(exists(tree.bottomFiveTxt), isTrue);
      final post = calculateHash(tree.bottomFiveTxt);
      expect(pre, equals(post));
    });

    test('multiple files absolute path that we delete', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        withFileProtection([tree.bottomFiveTxt, tree.bottomSixTxt], () {
          delete(tree.bottomFiveTxt);
          delete(tree.bottomSixTxt);
        });
        expect(exists(tree.bottomFiveTxt), isTrue);
        expect(exists(tree.bottomSixTxt), isTrue);
      });
    });

    test('multiple files relative path that we delete', () {
      final localDir = join(pwd, '.testing');
      final tree = TestDirectoryTree(localDir);

      withFileProtection(
          [relative(tree.bottomFiveTxt), relative(tree.bottomSixTxt)], () {
        delete(tree.bottomFiveTxt);
        delete(tree.bottomSixTxt);
      });
      expect(exists(tree.bottomFiveTxt), isTrue);
      expect(exists(tree.bottomSixTxt), isTrue);
    });

    test('directory absolute path that we delete', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        withFileProtection([tree.top], () {
          deleteDir(tree.top);
        });
        expect(exists(tree.top), isTrue);
        expect(exists(tree.topDotTwoTxt), isTrue);
        expect(exists(tree.topFredJpg), isTrue);
        expect(exists(tree.topFredPng), isTrue);
        expect(exists(tree.topOneJpg), isTrue);
        expect(exists(tree.topOneTxt), isTrue);
        expect(exists(tree.topTwoTxt), isTrue);
        expect(exists(tree.bottom), isTrue);
        expect(exists(tree.bottomFiveTxt), isTrue);
      });
    });

    test('directory relative path that we delete', () {
      final localDir = join(pwd, '.testing');
      final tree = TestDirectoryTree(localDir);

      withFileProtection([tree.top], () {
        deleteDir(tree.top);
      });
      expect(exists(tree.top), isTrue);
      expect(exists(tree.topDotTwoTxt), isTrue);
      expect(exists(tree.topFredJpg), isTrue);
      expect(exists(tree.topFredPng), isTrue);
      expect(exists(tree.topOneJpg), isTrue);
      expect(exists(tree.topOneTxt), isTrue);
      expect(exists(tree.topTwoTxt), isTrue);
      expect(exists(tree.bottom), isTrue);
      expect(exists(tree.bottomFiveTxt), isTrue);
    });

    // test('glob files that we delete', () {
    //   withTempDir((tempDir) {
    //     final tree = TestDirectoryTree(tempDir);

    //     withFileProtection(['*.txt'], () {
    //       delete(tree.topDotTwoTxt);
    //       delete(tree.middleFourTxt);
    //       delete(tree.middleDotFourTxt);
    //       deleteDir(tree.bottom);
    //     }, workingDirectory: tempDir);
    //     expect(exists(tree.topDotTwoTxt), isTrue);
    //     expect(exists(tree.middleFourTxt), isTrue);
    //     expect(exists(tree.middleDotFourTxt), isTrue);
    //     expect(exists(tree.bottom), isTrue);
    //     expect(exists(tree.bottomFiveTxt), isTrue);
    //   });
    // });

    test('single non-existent file', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        delete(tree.bottomFiveTxt);

        withFileProtection([tree.bottomFiveTxt], () {
          touch(tree.bottomFiveTxt, create: true);
        });
        expect(exists(tree.bottomFiveTxt), isFalse);
      });
    });

    test('non-existent directory', () async {
      await withTempDir((tempDir) async {
        final tree = TestDirectoryTree(tempDir);

        deleteDir(tree.bottom);

        withFileProtection([tree.bottom], () {
          createDir(tree.bottom, recursive: true);
          touch(tree.bottomFiveTxt, create: true);
        });
        expect(exists(tree.bottom), isFalse);
      });
    });

    test('translateAbsolutePath-linux', () async {
      await withTestScope((tempDir) async {
        final linuxContext = Context(style: Style.posix);
        expect(
          translateAbsolutePath(
            r'\',
            context: linuxContext,
            workingDirectory: '/',
          ),
          equals(r'\'),
        );
        expect(
          translateAbsolutePath(
            '/',
            context: linuxContext,
            workingDirectory: '/',
          ),
          equals('/'),
        );
        expect(
          translateAbsolutePath(
            r'\abc',
            context: linuxContext,
            workingDirectory: '/',
          ),
          equals(r'\abc'),
        );
        expect(
          translateAbsolutePath(
            '/abc',
            context: linuxContext,
            workingDirectory: '/',
          ),
          equals('/abc'),
        );
      }, overridePlatformOS: core.DCliPlatformOS.linux);
    }, skip: !Platform.isLinux);

    test('translateAbsolutePath-windows', () async {
      await withTestScope((tempDir) async {
        final windowsContext = Context(style: Style.windows);
        expect(
          translateAbsolutePath(
            r'\',
            context: windowsContext,
            workingDirectory: r'c:\',
          ),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(
            '/',
            context: windowsContext,
            workingDirectory: r'c:\',
          ),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(
            r'\abc',
            context: windowsContext,
            workingDirectory: r'c:\',
          ),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath(
            '/abc',
            context: windowsContext,
            workingDirectory: r'c:\',
          ),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath(
            r'\abc',
            context: windowsContext,
            workingDirectory: r'C:\User',
          ),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath(
            '/abc',
            context: windowsContext,
            workingDirectory: r'D:\User',
          ),
          equals(r'\DDrive\abc'),
        );

        expect(
          translateAbsolutePath(
            'c:/',
            context: windowsContext,
            workingDirectory: r'D:\User',
          ),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(
            'C:/abc',
            context: windowsContext,
            workingDirectory: r'D:\User',
          ),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath('c:/', context: windowsContext),
          equals(
            r'\CDrive',
          ),
        );
        expect(
          translateAbsolutePath('C:/', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath('c:/abc', context: windowsContext),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath('C:/abc', context: windowsContext),
          equals(r'\CDrive\abc'),
        );
        expect(
          translateAbsolutePath(r'c:\', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(r'C:\', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath('D:/', context: windowsContext),
          equals(r'\DDrive'),
        );
        expect(
          translateAbsolutePath('D:/', context: windowsContext),
          equals(r'\DDrive'),
        );
        expect(
          translateAbsolutePath(r'\\c:/', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(r'\\C:/', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(r'\\C:\', context: windowsContext),
          equals(r'\CDrive'),
        );
        expect(
          translateAbsolutePath(r'\\server', context: windowsContext),
          equals(r'\UNC\server'),
        );
        expect(
          translateAbsolutePath(r'\\server\abc', context: windowsContext),
          equals(r'\UNC\server\abc'),
        );
      }, overridePlatformOS: core.DCliPlatformOS.windows);
    });
  });
}
