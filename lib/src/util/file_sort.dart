import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/dshell.dart';
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

  Future _sort() async {
    var completer = Completer<void>();
    var instance = 1;
    var lineCount = 1000;

    var phaseDirectory = Directory.systemTemp.createTempSync();

    var list = <String>[];

    var sentToPhase = false;

    await File(filename)
        .openRead()
        .map(utf8.decode)
        .transform(LineSplitter())
        .forEach((l) async {
      list.add(l);
      lineCount--;

      if (lineCount == 0) {
        await savePhase(phaseDirectory, 1, instance, list, lineDelimiter);
        instance++;
        sentToPhase = true;
      }
    });

    if (!sentToPhase) {
      await _sortList(list);
      await overwrite(list);
    }
    completer.complete();

    return completer.future;
  }

  void overwrite(List<String> sorted) {
    move(filename, '$filename.bak');
    saveSortedList(filename, sorted, lineDelimiter);
    delete('$filename.bak');
  }

  void _sortList(List<String> list) {
    list.sort((lhs, rhs) {
      var lhsColumns = lhs.split(fieldDelimiter);
      var rhsColumns = rhs.split(fieldDelimiter);

      if (maxColumn > lhsColumns.length) {
        throw InvalidArguments('Line $lhs does not have enough columns');
      }

      if (maxColumn > rhsColumns.length) {
        throw InvalidArguments('Line $rhs does not have enough columns');
      }

      var result = 0;

      if (maxColumn == 0) {
        // just compare the whole line.
        result = columns[0].comparator.compareTo(lhs, rhs);
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
      List<String> list, String lineDelimiter) async {
    var instanceFile = File(join(phaseDirectory.path, 'phase$phase-$instance'));

    instanceFile.writeAsStringSync(list.join(lineDelimiter));
  }

  void saveSortedList(
      String filename, List<String> list, String lineDelimiter) async {
    var saveTo = FileSync(filename);

    saveTo.truncate();
    for (var line in list) {
      saveTo.append(line, newline: lineDelimiter);
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
