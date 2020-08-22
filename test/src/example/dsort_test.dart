@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/functions/is.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/util/dcli_exception.dart';
import 'package:dcli/src/util/file_sort.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  const rootTest = 'sort1';

  group('dsort tests', () {
    TestFileSystem().withinZone((fs) {
      var testFile = join(fs.root, rootTest, 'unsorted.txt');
      if (!exists(dirname(testFile))) {
        createDir(dirname(testFile), recursive: true);
      }

      test('dsort unsorted.txt', () {
        TestFileSystem().withinZone((fs) {
          try {
            var unsorted = [
              'b,Line',
              'd,Line',
              'a,Line',
            ];

            testFile.write(unsorted.join('\n'));

            var fileSort = FileSort(
                testFile,
                testFile,
                [Column(0, CaseInsensitiveSort(), SortDirection.ascending)],
                ',',
                '\n');
            fileSort.sort();
          } on DCliException catch (e) {
            print(e);
          }

          var expected = [
            'a,Line',
            'b,Line',
            'd,Line',
          ];
          var result = read(testFile).toList();
          expect(result, equals(expected));
        });
      });

      test('dsort --sortkey=1nd unsorted.txt', () {
        TestFileSystem().withinZone((fs) {
          var unsorted = [
            '4,Line',
            '7,Line',
            '1,Line',
          ];

          if (exists(testFile)) {
            delete(testFile);
          }
          testFile.write(unsorted.join('\n'));

          try {
            var fileSort = FileSort(
                testFile,
                testFile,
                [Column(1, NumericSort(), SortDirection.descending)],
                ',',
                '\n');
            fileSort.sort();
          } on DCliException catch (e) {
            print(e);
          }

          var expected = [
            '7,Line',
            '4,Line',
            '1,Line',
          ];
          var result = read(testFile).toList();
          expect(result, equals(expected));
        });
      });

      test('dsort unsorted.txt', () {
        TestFileSystem().withinZone((fs) {
          try {
            var unsorted = [
              'b,Line',
              'd,Line',
              'a,Line',
            ];

            testFile.write(unsorted.join('\n'));

            EntryPoint().process(['-v', 'example/dsort.dart', testFile]);
          } on DCliException catch (e) {
            print(e);
          }

          var expected = [
            'a,Line',
            'b,Line',
            'd,Line',
          ];
          var result = read(testFile).toList();
          expect(result, equals(expected));
        });
      });

      test('dsort --sortkey=1nd unsorted.txt', () {
        TestFileSystem().withinZone((fs) {
          var unsorted = [
            '4,Line',
            '7,Line',
            '1,Line',
          ];

          if (exists(testFile)) {
            delete(testFile);
          }
          testFile.write(unsorted.join('\n'));

          try {
            EntryPoint().process(
                ['example/dsort.dart', '-v', '--sortkey=1nd', testFile]);
          } on DCliException catch (e) {
            print(e);
          }

          var expected = [
            '7,Line',
            '4,Line',
            '1,Line',
          ];
          var result = read(testFile).toList();
          expect(result, equals(expected));
        });
      });

      test('dsort -f=: --sortkey=1nd,2,3Sd,5-7nd unsorted.txt', () {
        TestFileSystem().withinZone((fs) {
          try {
            var unsorted = [
              '4:Brett:Smith:a:1:2:3',
              '4:Brett:Smith:A:1:2:3',
              '4:Brett:Smith:A:2:2:3',
              '4:Brett:Smith:A:2:3:3',
              '4:Brett:Smith:A:2:3:4',
              '4:Brett:Sutton:D:1:2:3',
              '4:Don:Jones:D:1:2:3',
              '1:Deneille:Sutton:D:1:2:3',
            ];

            if (exists(testFile)) {
              delete(testFile);
            }
            testFile.write(unsorted.join('\n'));
            EntryPoint().process([
              'example/dsort.dart',
              '-f=:',
              '--sortkey=1nd,2,3Sd,5-7nd',
              testFile
            ]);
          } on DCliException catch (e) {
            print(e);
          }

          var expected = [
            '4:Brett:Smith:a:1:2:3',
            '4:Brett:Smith:A:1:2:3',
            '4:Brett:Smith:A:2:2:3',
            '4:Brett:Smith:A:2:3:3',
            '4:Brett:Smith:A:2:3:4',
            '4:Brett:Sutton:D:1:2:3',
            '4:Don:Jones:D:1:2:3',
            '1:Deneille:Sutton:D:1:2:3',
          ];
          var result = read(testFile).toList();
          expect(result, equals(expected));
        });
      });
    });
  });
}
