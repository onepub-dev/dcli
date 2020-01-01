import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/dshell.dart' as d;
import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/util/waitForEx.dart';

class FileSort {
  final String filename;
  final List<Column> columns;
  final String fieldDelimiter;
  final String lineDelimiter;
  int maxColumn = -1;

  FileSort(
      this.filename, this.columns, this.fieldDelimiter, this.lineDelimiter) {
    for (var column in columns) {
      if (maxColumn < column.ordinal) {
        maxColumn = column.ordinal;
      }
    }
  }

  void sort() {
    waitForEx<void>(_sort());
  }

  static const MERGE_SIZE = 1000;
  Future _sort() async {
    var completer = Completer<void>();
    var instance = 0;
    var lineCount = MERGE_SIZE;

    var phaseDirectory = Directory.systemTemp.createTempSync();

    var list = <Line>[];

    var sentToPhase = false;

    var phaseFutures = <Future<void>>[];

    await File(filename)
        .openRead()
        .map(utf8.decode)
        .transform(LineSplitter())
        .forEach((l) async {
      list.add(Line.fromString(l));
      lineCount--;

      if (lineCount == 0) {
        lineCount = MERGE_SIZE;
        var phaseList = list;
        list = [];
        instance++;
        sentToPhase = true;
        var phaseFuture = Completer<void>();
        phaseFutures.add(phaseFuture.future);

        await savePhase(phaseDirectory, 1, instance, phaseList, lineDelimiter);
        phaseFuture.complete(null);
      }
    });

    if (!sentToPhase) {
      await _sortList(list);
      await replaceFileWithSortedList(list);
    } else {
      if (list.isNotEmpty && list.length < MERGE_SIZE) {
        await savePhase(phaseDirectory, 1, ++instance, list, lineDelimiter);
      }
      await Future.wait(phaseFutures);
      await _mergeSort(phaseDirectory);
    }
    completer.complete();

    return completer.future;
  }

  void replaceFileWithSortedList(List<Line> sorted) {
    d.move(filename, '$filename.bak');
    saveSortedList(filename, sorted, lineDelimiter);
    d.delete('$filename.bak');
  }

  /// Performs an insitu sort of the passed list.
  void _sortList(List<Line> list) {
    list.sort((lhs, rhs) {
      var lhsColumns = lhs.line.split(fieldDelimiter);
      var rhsColumns = rhs.line.split(fieldDelimiter);

      if (maxColumn > lhsColumns.length) {
        throw InvalidArguments('Line $lhs does not have enough columns');
      }

      if (maxColumn > rhsColumns.length) {
        throw InvalidArguments('Line $rhs does not have enough columns');
      }

      var result = 0;

      if (maxColumn == 0) {
        // just compare the whole line.
        result = columns[0].comparator.compareTo(lhs.line, rhs.line);
      } else {
        // compare the defined columns
        for (var column in columns) {
          var direction =
              column.sortDirection == SortDirection.Ascending ? 1 : -1;

          result = column.comparator.compareTo(lhsColumns[column.ordinal - 1],
                  rhsColumns[column.ordinal - 1]) *
              direction;
          if (result != 0) {
            break;
          }
        }
      }
      return result;
    });
  }

  void savePhase(Directory phaseDirectory, int phase, int instance,
      List<Line> list, String lineDelimiter) async {
    var instanceFile =
        await File(d.join(phaseDirectory.path, 'phase$phase-$instance'));

    await _sortList(list);

    var lines = list.map((line) => line.line).toList();

    instanceFile.writeAsStringSync(lines.join(lineDelimiter) + lineDelimiter,
        flush: true);
  }

  void saveSortedList(
      String filename, List<Line> list, String lineDelimiter) async {
    var saveTo = d.FileSync(filename);

    saveTo.truncate();
    for (var line in list) {
      saveTo.append(line.line, newline: lineDelimiter);
    }
  }

  static List<Column> expandColumns(List<String> values) {
    var columns = <Column>[];

    for (var value in values) {
      var parts = value.split('-');

      if (parts.length == 1) {
        columns.add(Column.parse(parts[0]));
      } else if (parts.length == 2) {
        // We have been passed a column range 1-4
        // The type and sort direction MUST ONLY be present on the end ordinal
        // e.g. 1-4Sa

        var end = Column.parse(parts[1]);

        var comparator = end.comparator;
        var sortDirection = end.sortDirection;

        var start = Column.parse(parts[0], ordinalOnly: true);
        start.comparator = comparator;
        start.sortDirection = sortDirection;

        int index;
        if (end.ordinal > start.ordinal) {
          index = 1;
        } else {
          index = -1;
        }
        columns.add(start);

        for (var i = start.ordinal + index; i != end.ordinal; i += index) {
          var column = Column(i, comparator, sortDirection);
          columns.add(column);
        }

        columns.add(end);
      } else {
        throw InvalidArguments('The column format is invalid: $value');
      }
    }

    return columns;
  }

  /// Performs a merge sort
  /// We open every file in the phase directory
  /// and then read the first line from each file.
  /// We then sort the list of the first lines.
  /// We write the first line from the resulting sort
  /// to the merge file noting what file the line
  /// was read from.
  /// We then read another line from the noted file
  /// repeat the sort and the write.
  /// if noted file is empty when then write
  /// the first line from the sorted list
  /// and write that line.
  /// Rinse and repeat until all files are drained
  /// and the list is empty.
  void _mergeSort(Directory phaseDirectory) {
    var lines = <Line>[];
    var files = d.find('*', root: phaseDirectory.path).toList();

    // Open and read the first line from each file.
    for (var file in files) {
      var fileSync = d.FileSync(file, fileMode: FileMode.read);
      lines.add(Line(fileSync));
    }

    // Sort the set of first lines.
    _sortList(lines);

    var mergedFilename = 'merged.txt';
    var mergedPath = d.join(phaseDirectory.path, mergedFilename);
    var result = d.FileSync(mergedPath, fileMode: FileMode.writeOnlyAppend);

    while (lines.isNotEmpty) {
      var line = lines.removeAt(0);
      result.append(line.line);

      // a btree might give better performance as we wouldn't
      // have to resort.
      // If readNext returns false then the file is drained
      // so we don't re-added to the list.
      if (line.readNext()) {
        lines.add(line);
        _sortList(lines);
      } else {
        line.close();
        line.delete();
      }
    }

    d.move(filename, '$filename.bak');
    d.move(mergedPath, '$filename');
    d.delete('$filename.bak');
    d.deleteDir(phaseDirectory.path);
  }
}

class Line {
  d.FileSync source;
  String line;

  Line(this.source) {
    line = source.readLine();
  }

  Line.fromString(this.line);

  bool readNext() {
    line = source.readLine();
    return line != null;
  }

  void close() {
    source.close();
  }

  void delete() {
    d.delete(source.path);
  }
}

enum SortDirection { Ascending, Descending }

class CaseInsensitiveSort implements ColumnComparator {
  const CaseInsensitiveSort();
  @override
  int compareTo(String lhs, String rhs) {
    return lhs.toLowerCase().compareTo(rhs.toLowerCase());
  }
}

class CaseSensitiveSort implements ColumnComparator {
  const CaseSensitiveSort();
  @override
  int compareTo(String lhs, String rhs) {
    return lhs.compareTo(rhs);
  }
}

class NumericSort implements ColumnComparator {
  const NumericSort();
  @override
  int compareTo(String lhs, String rhs) {
    var numLhs = num.parse(lhs);
    var numRhs = num.parse(rhs);
    return numLhs.compareTo(numRhs);
  }
}

class MonthSort implements ColumnComparator {
  const MonthSort();
  @override
  int compareTo(String lhs, String rhs) {
    var mLhs = toMonthNo(lhs);
    var mRhs = toMonthNo(rhs);
    return mLhs.compareTo(mRhs);
  }

  static const Map<String, int> months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// the month no. (base 1) derived
  /// from the monthName.
  /// checks are case insensitive and only the first three
  /// characters are considered.
  int toMonthNo(String monthName) {
    monthName = monthName.trim();
    if (monthName.length < 3) {
      throw InvalidArguments('Month in must be at least 3 characters long');
    }
    monthName = monthName.substring(0, 3).toLowerCase();

    return months[monthName];
  }
}

abstract class ColumnComparator {
  int compareTo(String lhs, String rhs);
}

class Column {
  static const typeMap = {
    's': CaseInsensitiveSort(),
    'S': CaseSensitiveSort(),
    'n': NumericSort(),
    'm': MonthSort(),
  };

  static const directionMap = {
    'a': SortDirection.Ascending,
    'd': SortDirection.Descending
  };

  /// [ordinal] is the column index using base 1
  /// An ordinal of 0 means that we are treating the entire
  /// line as a single column.
  int ordinal;
  ColumnComparator comparator;
  SortDirection sortDirection;

  Column(this.ordinal, this.comparator, this.sortDirection);

  /// A column string is formed as:
  /// [ordinal]<type><direction>
  ///
  /// [ordinal] - the column no. base 1
  /// <type>=<s|S|n|m>
  /// s - case sensitive string sort - the default
  /// S - case insensitive string sort
  /// n - numeric sort
  /// m - month name sort
  ///
  /// If the [direction] is specified then you must also specifiy the type
  /// [direction]=<a|d>
  /// a - ascending - the default
  /// d - descending
  ///
  Column.parse(String column, {bool ordinalOnly = false}) {
    var digits = countDigits(column);

    ordinal = int.parse(column.substring(0, digits));

    if (ordinalOnly && digits < column.length) {
      throw InvalidArguments('Expected only a column no but found: $column');
    }

    var type = 's';

    if (column.length > digits) {
      type = column.substring(digits, digits + 1);
    }

    comparator = typeMap[type];

    if (comparator == null) {
      throw InvalidArguments('The sort type $type is not valid');
    }

    var direction = 'a';

    if (column.length > digits + 1) {
      direction = column.substring(digits + 1, digits + 2);
    }
    sortDirection = directionMap[direction];

    if (sortDirection == null) {
      throw InvalidArguments('The sort direction $direction is not valid');
    }
  }

  int countDigits(String column) {
    var digits = 0;

    for (var i = 0; i < column.length; i++) {
      if (!isDigit(column[i])) {
        break;
      }
      digits++;
    }
    return digits;
  }

  bool isDigit(String c) {
    return c == '0' ||
        c == '1' ||
        c == '2' ||
        c == '3' ||
        c == '4' ||
        c == '5' ||
        c == '6' ||
        c == '7' ||
        c == '8' ||
        c == '9';
  }
}
