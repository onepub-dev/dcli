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
      TestFileSystem().withinZone((fs) {
        var foundDirs = find('*',
                root: fs.testScriptPath,
                recursive: false,
                types: <FileSystemEntityType>[Find.directory],
                includeHidden: true)
            .toList();

        var rootDirs = <String>[
          join(fs.testScriptPath, 'general'),
          join(fs.testScriptPath, 'traditional_project')
        ];

        expect(foundDirs, t.unorderedEquals(rootDirs));
      });
    });

    test('Recurse entire filesystem', () {
      // var count = 1;

      print(DateTime.now());
      find(
        '*',
        root: '/',
        recursive: true,
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
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.txt', root: paths.top, recursive: false).toList();
        found.sort();
        var expected = [join(paths.top, 'one.txt'), join(paths.top, 'two.txt')];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.jpg ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.jpg', root: paths.top).toList();

        find('*.jpg', root: paths.top).forEach(print);
        t.expect(find('one.jpg', root: paths.top).toList(),
            t.equals([join(paths.top, 'one.jpg')]));

        t.expect(find('two.jpg', root: paths.top).toList(),
            t.equals([join(paths.middle, 'two.jpg')]));

        find('*.jpg', progress: Progress(print));

        found.sort();
        var expected = [
          join(paths.top, 'fred.jpg'),
          join(paths.top, 'one.jpg'),
          join(paths.middle, 'two.jpg'),
          join(paths.bottom, 'three.jpg')
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('Search recursive for *.txt ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.txt', root: paths.top).toList();

        found.sort();
        var expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt')
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('ignore hidden files *.txt  ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found = find('*.txt', root: paths.top).toList();

        found.sort();
        var expected = [
          join(paths.top, 'one.txt'),
          join(paths.top, 'two.txt'),
          join(paths.middle, 'three.txt'),
          join(paths.middle, 'four.txt'),
          join(paths.bottom, 'five.txt'),
          join(paths.bottom, 'six.txt'),
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('find hidden files *.txt  ', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        var found =
            find('*.txt', root: paths.top, includeHidden: true).toList();

        found.sort();
        var expected = [
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
        ];
        expected.sort();
        t.expect(found, t.equals(expected));
      });
    });

    t.test('non-recursive find', () async {
      var tmp = Directory('/tmp').createTempSync().path;

      var paths = <String>[
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

      for (var file in paths) {
        if (!exists(dirname(file))) {
          createDir(dirname(file));
        }
        touch(file, create: true);
      }

      var found = find('*.txt', root: tmp, includeHidden: true).toList();

      t.expect(found, t.unorderedEquals(paths));
    });
  });
}
