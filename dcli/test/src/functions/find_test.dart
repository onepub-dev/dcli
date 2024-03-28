@Timeout(Duration(seconds: 1200))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('Find', () {
    t.test('manualRecursion', () async {
      final testScriptPath = truepath(DartProject.self.pathToProjectRoot, '..',
          'dcli_unit_tester', 'test', 'test_script');

      final foundDirs = find(
        '*',
        workingDirectory: testScriptPath,
        recursive: false,
        types: <FileSystemEntityType>[Find.directory],
        includeHidden: true,
      ).toList();

      final rootDirs = <String>[
        truepath(testScriptPath, 'dcli_unit_tester'),
        truepath(testScriptPath, 'general'),
        truepath(testScriptPath, 'traditional_project')
      ];

      expect(foundDirs, t.unorderedEquals(rootDirs));
    });

    test('Large directory tree', () {
      withTempDir((root) {
        var expected = <String>[];
        for (var i = 0; i < 110; i++) {
          final path = join(root, '$i');
          createDir(path, recursive: true);
          final pathToLicense = join(path, 'LICENSE$i');
          touch(pathToLicense, create: true);
          expected
            ..add(path)
            ..add(pathToLicense);
        }
// /mnt/c/Users/Brett/AppData/Local/Pub/Cache/hosted/pub.dartlang.org'
        expected = expected
            //map((path) => join(rootPath, relative(path, from: '/mnt/c')))
            .toList()
          ..sort((lhs, rhs) => lhs.compareTo(rhs));

        final actual = find(
          '*',
          includeHidden: true,
          types: [Find.directory, Find.file],
          workingDirectory: root,
        ).toList()
          ..sort((lhs, rhs) => lhs.compareTo(rhs));

        expect(actual, t.orderedEquals(expected));
      });
    });

    test(
      'Recurse home directory',
      () {
        var count = 1;

        print(DateTime.now());
        find(
          '*',
          workingDirectory: join('/', 'home', env['USER']),
          types: <FileSystemEntityType>[Find.directory],
          includeHidden: true,
          // progress: Progress((line) {
          // if (count++ % 10000 == 0) print(count);
          // if (count == 100000) {
          //   //print(DateTime.now());
          //  // dcliExit(1);
          // }
          // }),
        ).forEach((line) {
          if (count++ % 10000 == 0) {
            print(count);
          }
        });
        expect(true, isTrue);
      },
      skip: true,
    ); // takes too long to run

    // test('hidden a', () {
    //   var count = 0;
    //   var withHidden = find(
    //     '*',
    //     root: '/',
    //     recursive: true,
    //     types: <FileSystemEntityType>[Find.directory],
    //     includeHidden: true,
    //     progress: Progress((line) {
    //       if (count++ % 1000 == 0) print(count);
    //     }),
    //   ).toList();
    //   count = 1;
    //   var withOutHidden = find(
    //     '*',
    //     root: '/',
    //     recursive: true,
    //     types: <FileSystemEntityType>[Find.directory],
    //     includeHidden: false,
    //     progress: Progress((line) {
    //       if (count++ % 1000 == 0) print(count);
    //     }),
    //   ).toList();

    //   // print(withHidden.length);

    //   expect(withHidden, t.isNot(t.unorderedEquals(withOutHidden)));

    //   expect(withHidden.length, t.lessThan(withOutHidden.length));
    // }, skip: false); // takes
  });

  t.group('Find', () {
    t.test('Search for *.txt files in top directory ', () {
      withTempDir((fsRoot) {
        final paths = TestDirectoryTree(fsRoot);
        final found =
            find('*.txt', workingDirectory: paths.top, recursive: false)
                .toList()
              ..sort();
        final expected = [
          truepath(paths.top, 'one.txt'),
          truepath(paths.top, 'two.txt')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.jpg ', () {
      withTempDir((fsRoot) {
        final paths = TestDirectoryTree(fsRoot);
        final found = find('*.jpg', workingDirectory: paths.top).toList();

        find('*.jpg', workingDirectory: paths.top).forEach(print);
        t.expect(
          find('one.jpg', workingDirectory: paths.top).toList(),
          t.equals([truepath(paths.top, 'one.jpg')]),
        );

        t.expect(
          find('two.jpg', workingDirectory: paths.top).toList(),
          t.equals([truepath(paths.middle, 'two.jpg')]),
        );

        find('*.jpg', progress: Progress(print));

        found.sort();
        final expected = [
          truepath(paths.top, 'fred.jpg'),
          truepath(paths.top, 'one.jpg'),
          truepath(paths.middle, 'two.jpg'),
          truepath(paths.bottom, 'three.jpg')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.txt ', () {
      withTempDir((fsRoot) {
        final paths = TestDirectoryTree(fsRoot);
        final found = find('*.txt', workingDirectory: paths.top).toList()
          ..sort();
        final expected = [
          truepath(paths.top, 'one.txt'),
          truepath(paths.top, 'two.txt'),
          truepath(paths.middle, 'three.txt'),
          truepath(paths.middle, 'four.txt'),
          truepath(paths.bottom, 'five.txt'),
          truepath(paths.bottom, 'six.txt')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('ignore hidden files *.txt  ', () {
      withTempDir((fsRoot) {
        final paths = TestDirectoryTree(fsRoot);
        final found = find('*.txt', workingDirectory: paths.top).toList()
          ..sort();
        final expected = [
          truepath(paths.top, 'one.txt'),
          truepath(paths.top, 'two.txt'),
          truepath(paths.middle, 'three.txt'),
          truepath(paths.middle, 'four.txt'),
          truepath(paths.bottom, 'five.txt'),
          truepath(paths.bottom, 'six.txt'),
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('find hidden files *.txt  ', () {
      withTempDir((fsRoot) {
        final paths = TestDirectoryTree(fsRoot);
        final found =
            find('*.txt', workingDirectory: paths.top, includeHidden: true)
                .toList()
              ..sort();
        final expected = [
          truepath(paths.thidden, 'fred.txt'),
          truepath(paths.top, 'one.txt'),
          truepath(paths.top, 'two.txt'),
          truepath(paths.top, '.two.txt'),
          truepath(paths.middle, 'three.txt'),
          truepath(paths.middle, 'four.txt'),
          truepath(paths.middle, '.four.txt'),
          truepath(paths.bottom, 'five.txt'),
          truepath(paths.bottom, 'six.txt'),
          truepath(paths.hidden, 'seven.txt'),
          truepath(paths.hidden, '.seven.txt'),
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('non-recursive find', () async {
      withTempDir((tmp) {
        final paths = <String>[
          truepath(tmp, '.thidden' 'fred.txt'),
          truepath(tmp, 'top', 'one.txt'),
          truepath(tmp, 'top', 'two.txt'),
          truepath(tmp, 'top', '.two.txt'),
          truepath(tmp, 'middle', 'three.txt'),
          truepath(tmp, 'middle', 'four.txt'),
          truepath(tmp, 'middle', '.four.txt'),
          truepath(tmp, 'bottom', 'five.txt'),
          truepath(tmp, 'bottom', 'six.txt'),
          truepath(tmp, '.hidden', 'seven.txt'),
          truepath(tmp, '.hidden', '.seven.txt')
        ];

        for (final file in paths) {
          if (!exists(dirname(file))) {
            createDir(dirname(file));
          }
          touch(file, create: true);
        }

        final found =
            find('*.txt', workingDirectory: tmp, includeHidden: true).toList();

        t.expect(found, t.unorderedEquals(paths));
      });
    });

    t.test('non-recursive find with path in pattern', () async {
      withTempDir((tmp) {
        final paths = <String>[
          truepath(tmp, 'middle', 'three.txt'),
          truepath(tmp, 'middle', 'four.txt'),
          truepath(tmp, 'middle', '.four.txt'),
        ];

        for (final file in paths) {
          if (!exists(dirname(file))) {
            createDir(dirname(file));
          }
          touch(file, create: true);
        }

        final found = find(
          join('middle', '*.txt'),
          workingDirectory: tmp,
          recursive: false,
          includeHidden: true,
        ).toList();

        t.expect(found, t.unorderedEquals(paths));
      });
    });

    t.test('recursive find with path in pattern', () async {
      withTempDir((tmp) {
        final paths = <String>[
          truepath(tmp, 'middle', 'three.txt'),
          truepath(tmp, 'middle', 'four.txt'),
          truepath(tmp, 'middle', '.four.txt'),
        ];

        for (final file in paths) {
          if (!exists(dirname(file))) {
            createDir(dirname(file));
          }
          touch(file, create: true);
        }

        final found = find(
          join('middle', '*.txt'),
          workingDirectory: tmp,
          includeHidden: true,
        ).toList();

        t.expect(found, t.unorderedEquals(paths));
      });
    });

    t.test('recursive find with absolute path in pattern', () async {
      withTempDir((tmp) {
        final paths = <String>[
          truepath(tmp, 'middle', 'three.txt'),
          truepath(tmp, 'middle', 'four.txt'),
          truepath(tmp, 'middle', '.four.txt'),
        ];

        for (final file in paths) {
          if (!exists(dirname(file))) {
            createDir(dirname(file));
          }
          touch(file, create: true);
        }

        final found = find(
          join(tmp, 'middle', '*.txt'),
          workingDirectory: tmp,
          includeHidden: true,
        ).toList();

        t.expect(found, t.unorderedEquals(paths));
      });
    });
  });

  test('do not follow links', () {
    expect(isLink('/usr/bin/X11'), isTrue);
    find('*', workingDirectory: '/usr/bin').forEach(print);
  }, skip: core.Settings().isWindows);
}
