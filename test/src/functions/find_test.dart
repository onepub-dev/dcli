@Timeout(Duration(seconds: 600))
import 'dart:io';
import 'package:dcli/src/util/progress.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Find', () {
    t.test('manualRecursion', () async {
      final testScriptPath =
          join(DartScript.current.pathToProjectRoot, 'test', 'test_script');
      final foundDirs = find('*',
              workingDirectory: testScriptPath,
              recursive: false,
              types: <FileSystemEntityType>[Find.directory],
              includeHidden: true)
          .toList();

      final rootDirs = <String>[
        join(testScriptPath, 'general'),
        join(testScriptPath, 'traditional_project')
      ];

      expect(foundDirs, t.unorderedEquals(rootDirs));
    });

    test('Recurse entire filesystem', () {
      // var count = 1;

      print(DateTime.now());
      find(
        '*',
        workingDirectory: '/',
        types: <FileSystemEntityType>[Find.directory],
        includeHidden: true,
        // progress: Progress((line) {
        // if (count++ % 10000 == 0) print(count);
        // if (count == 100000) {
        //   //print(DateTime.now());
        //  // exit(1);
        // }
        // }),
      );
    }, skip: true); // takes too long to run

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
        final paths = TestFileSystem()..build(fsRoot);
        final found =
            find('*.txt', workingDirectory: paths.top, recursive: false)
                .toList()
                  ..sort();
        final expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.jpg ', () {
      withTempDir((fsRoot) {
        final paths = TestFileSystem()..build(fsRoot);
        final found = find('*.jpg', workingDirectory: paths.top).toList();

        find('*.jpg', workingDirectory: paths.top).forEach(print);
        t.expect(find('one.jpg', workingDirectory: paths.top).toList(),
            t.equals([join(paths.top, 'one.jpg')]));

        t.expect(find('two.jpg', workingDirectory: paths.top).toList(),
            t.equals([join(paths.middle, 'two.jpg')]));

        find('*.jpg', progress: Progress(print));

        found.sort();
        final expected = [
          join(paths.top, 'fred.jpg'),
          join(paths.top, 'one.jpg'),
          join(paths.middle, 'two.jpg'),
          join(paths.bottom, 'three.jpg')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.txt ', () {
      withTempDir((fsRoot) {
        final paths = TestFileSystem()..build(fsRoot);
        final found = find('*.txt', workingDirectory: paths.top).toList()
          ..sort();
        final expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt')
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('ignore hidden files *.txt  ', () {
      withTempDir((fsRoot) {
        final paths = TestFileSystem()..build(fsRoot);
        final found = find('*.txt', workingDirectory: paths.top).toList()
          ..sort();
        final expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt'),
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('find hidden files *.txt  ', () {
      withTempDir((fsRoot) {
        final paths = TestFileSystem()..build(fsRoot);
        final found =
            find('*.txt', workingDirectory: paths.top, includeHidden: true)
                .toList()
                  ..sort();
        final expected = [
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
        ]..sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('non-recursive find', () async {
      final tmp = Directory('/tmp').createTempSync().path;

      final paths = <String>[
        join(tmp, '.thidden' 'fred.txt'),
        join(tmp, 'top', 'one.txt'),
        join(tmp, 'top', 'two.txt'),
        join(tmp, 'top', '.two.txt'),
        join(tmp, 'middle', 'three.txt'),
        join(tmp, 'middle', 'four.txt'),
        join(tmp, 'middle', '.four.txt'),
        join(tmp, 'bottom', 'five.txt'),
        join(tmp, 'bottom', 'six.txt'),
        join(tmp, '.hidden', 'seven.txt'),
        join(tmp, '.hidden', '.seven.txt')
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

    t.test('non-recursive find with path in pattern', () async {
      final tmp = Directory('/tmp').createTempSync().path;

      final paths = <String>[
        join(tmp, 'middle', 'three.txt'),
        join(tmp, 'middle', 'four.txt'),
        join(tmp, 'middle', '.four.txt'),
      ];

      for (final file in paths) {
        if (!exists(dirname(file))) {
          createDir(dirname(file));
        }
        touch(file, create: true);
      }

      final found = find('middle/*.txt',
              workingDirectory: tmp, recursive: false, includeHidden: true)
          .toList();

      t.expect(found, t.unorderedEquals(paths));
    });

    t.test('recursive find with path in pattern', () async {
      final tmp = Directory('/tmp').createTempSync().path;

      final paths = <String>[
        join(tmp, 'middle', 'three.txt'),
        join(tmp, 'middle', 'four.txt'),
        join(tmp, 'middle', '.four.txt'),
      ];

      for (final file in paths) {
        if (!exists(dirname(file))) {
          createDir(dirname(file));
        }
        touch(file, create: true);
      }

      final found =
          find('middle/*.txt', workingDirectory: tmp, includeHidden: true)
              .toList();

      t.expect(found, t.unorderedEquals(paths));
    });
  });
}
