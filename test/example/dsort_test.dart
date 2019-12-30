import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/util/file_sort.dart';
import 'package:test/test.dart';

import '../test_settings.dart';

void main() {
  group('sort', () {
    test('simple sort', () {
      if (!exists(TEST_ROOT)) {
        createDir(TEST_ROOT, recursive: true);
      }

      var unsortedFile = 'unsorted.txt';
      unsortedFile.truncate();

      for (var i = 9; i > 0; i--) {
        unsortedFile.append('$i line');
      }

      FileSort(unsortedFile, [Column.parse('0')], ',', '\n').sort();

      var expected = <String>[];
      for (var i = 1; i <= 9; i++) {
        expected.add('$i line');
      }

      var sorted = read(unsortedFile).toList();

      expect(sorted, equals(expected));
    });

    test('column sort -2', () {
      if (!exists(TEST_ROOT)) {
        createDir(TEST_ROOT, recursive: true);
      }
      var unsortedFile = 'unsorted.txt';
      unsortedFile.truncate();

      for (var i = 9; i > 0; i--) {
        unsortedFile.append('line, $i');
      }

      FileSort(unsortedFile, [Column.parse('2')], ',', '\n').sort();

      var expected = <String>[];
      for (var i = 1; i <= 9; i++) {
        expected.add('line, $i');
      }

      var sorted = read(unsortedFile).toList();

      expect(sorted, equals(expected));
    });

    test('Col 2 Case Insensative Ascending -2sa', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(unsortedFile, [Column.parse('2sa')], ',', '\n');

      var generated = <String>[];

      for (var i = 9; i >= 0; i--) {
        generated.add('line, $i');
      }

      var expected = <String>[];
      for (var i = 0; i <= 9; i++) {
        expected.add('line, $i');
      }
      runSortTest(fileSort, expected, generated);
    });

    test('Col 2 Case Insensative Descending -2sd', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(unsortedFile, [Column.parse('2sd')], ',', '\n');

      var generated = <String>[];

      for (var i = 0; i <= 9; i++) {
        generated.add('line, $i');
      }

      var expected = <String>[];
      for (var i = 9; i >= 0; i--) {
        expected.add('line, $i');
      }
      runSortTest(fileSort, expected, generated);
    });

    test('Col 1 Case Sensative Descending -1Sd', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(unsortedFile, [Column.parse('1Sd')], ',', '\n');

      var generated = <String>[];

      for (var i = 0; i <= 9; i++) {
        generated.add('${genChar('A', i)} line, $i');
      }

      for (var i = 0; i <= 9; i++) {
        generated.add('${genChar('a', i)} line, $i');
      }

      var expected = <String>[];
      for (var i = 9; i >= 0; i--) {
        expected.add('${genChar('a', i)} line, $i');
      }
      for (var i = 9; i >= 0; i--) {
        expected.add('${genChar('A', i)} line, $i');
      }
      runSortTest(fileSort, expected, generated);
    });

    test('Col 2 Case numeric Descending -2nd', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(unsortedFile, [Column.parse('2nd')], ',', '\n');

      var generated = <String>[];

      for (var i = 0; i <= 20; i++) {
        generated.add('line, $i');
      }

      var expected = <String>[];
      for (var i = 20; i >= 0; i--) {
        expected.add('line, $i');
      }
      runSortTest(fileSort, expected, generated);
    });

    test('Col 2 Case MONTH Descending -2md', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(unsortedFile, [Column.parse('2md')], ',', '\n');

      var monthList = <String>[
        'January',
        'Feburary',
        'March',
        'April',
        'May',
        'June',
        'July',
        'august',
        'sept',
        'october',
        'november',
        'decem'
      ];

      var generated = <String>[];

      for (var month in monthList) {
        generated.add('line, $month');
      }

      var expected = <String>[];

      for (var month in monthList.reversed) {
        expected.add('line, $month');
      }
      runSortTest(fileSort, expected, generated);
    });

    test('Multi column -1m, 2', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(
          unsortedFile, FileSort.expandColumns(['3m', '2nd']), ',', '\n');
      var generated = <String>[
        'Line, 21, Feb',
        'Line, 10, march',
        'Line, 1, Jan',
        'Line, 2, Jan',
        'Line, 3, Jan',
      ];

      var expected = <String>[
        'Line, 3, Jan',
        'Line, 2, Jan',
        'Line, 1, Jan',
        'Line, 21, Feb',
        'Line, 10, march',
      ];

      runSortTest(fileSort, expected, generated);
    });

    test('Range column 1-3', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort =
          FileSort(unsortedFile, FileSort.expandColumns(['1-3']), ',', '\n');

      expect(fileSort.columns.length, equals(3));
      expect(fileSort.columns[0].ordinal, equals(1));
      expect(
          fileSort.columns[0].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[0].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[1].ordinal, equals(2));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[1].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[2].ordinal, equals(3));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[2].comparator, equals(const CaseInsensitiveSort()));
    });

    test('Range column 5-3', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort =
          FileSort(unsortedFile, FileSort.expandColumns(['5-3']), ',', '\n');

      expect(fileSort.columns.length, equals(3));
      expect(fileSort.columns[0].ordinal, equals(5));
      expect(
          fileSort.columns[0].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[0].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[1].ordinal, equals(4));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[1].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[2].ordinal, equals(3));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[2].comparator, equals(const CaseInsensitiveSort()));
    });

    test('Double Range column 5-3,1-2', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(
          unsortedFile, FileSort.expandColumns(['5-3', '1-2']), ',', '\n');

      expect(fileSort.columns.length, equals(5));
      expect(fileSort.columns[0].ordinal, equals(5));
      expect(
          fileSort.columns[0].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[0].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[1].ordinal, equals(4));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[1].comparator, equals(const CaseInsensitiveSort()));
      expect(fileSort.columns[2].ordinal, equals(3));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[2].comparator, equals(const CaseInsensitiveSort()));

      expect(fileSort.columns[3].ordinal, equals(1));
      expect(
          fileSort.columns[3].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[3].comparator, equals(const CaseInsensitiveSort()));

      expect(fileSort.columns[4].ordinal, equals(2));
      expect(
          fileSort.columns[4].sortDirection, equals(SortDirection.Ascending));
      expect(
          fileSort.columns[4].comparator, equals(const CaseInsensitiveSort()));
    });

    test('Double Range  With types  5-3md,1-2na', () {
      var unsortedFile = 'unsorted.txt';
      var fileSort = FileSort(
          unsortedFile, FileSort.expandColumns(['5-3md', '1-2na']), ',', '\n');

      expect(fileSort.columns.length, equals(5));
      expect(fileSort.columns[0].ordinal, equals(5));
      expect(
          fileSort.columns[0].sortDirection, equals(SortDirection.Descending));
      expect(fileSort.columns[0].comparator, equals(const MonthSort()));
      expect(fileSort.columns[1].ordinal, equals(4));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Descending));
      expect(fileSort.columns[1].comparator, equals(const MonthSort()));
      expect(fileSort.columns[2].ordinal, equals(3));
      expect(
          fileSort.columns[2].sortDirection, equals(SortDirection.Descending));
      expect(fileSort.columns[2].comparator, equals(const MonthSort()));

      expect(fileSort.columns[3].ordinal, equals(1));
      expect(
          fileSort.columns[3].sortDirection, equals(SortDirection.Ascending));
      expect(fileSort.columns[3].comparator, equals(const NumericSort()));

      expect(fileSort.columns[4].ordinal, equals(2));
      expect(
          fileSort.columns[4].sortDirection, equals(SortDirection.Ascending));
      expect(fileSort.columns[4].comparator, equals(const NumericSort()));
    });
  });
}

String genChar(String c, int offset) {
  return String.fromCharCode(c.codeUnitAt(0) + offset);
}

void runSortTest(
    FileSort fileSort, List<String> expected, List<String> generated) {
  if (!exists(TEST_ROOT)) {
    createDir(TEST_ROOT, recursive: true);
  }

  fileSort.filename.truncate();

  for (var line in generated) {
    fileSort.filename.append(line);
  }

  fileSort.sort();

  var sorted = read(fileSort.filename).toList();

  expect(sorted, equals(expected));
  deleteDir(TEST_ROOT);
}
