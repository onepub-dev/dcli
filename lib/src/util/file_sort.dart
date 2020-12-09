import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';

import '../../dcli.dart' as d;
import '../script/command_line_runner.dart';
import 'file_sync.dart';
import 'wait_for_ex.dart';

/// FileSort provides the ability to sort files
/// based on their columns.
///
/// FileSort does a file based merge sort and as
/// such can sort large files without regard to
/// memory constraints.
/// You will need free disk space equivalent to
/// 2 times the size of the [_inputPath] file.
///
/// FileSort provides a range of sort comparators including:
/// String - case sensitive and case insenstive
/// Numeric
/// Month
///
/// FileSort is used by the DCli example apps
/// dsort.dart to re-implement the standard cli
/// tool 'sort'.
///
/// [_inputPath] is the path to the file to be sorted
/// [_outputPath] is the path to write the sorted file to.
/// [_columns] is used to describe the sort order to be
/// applied to the selected columns.
/// [_fieldDelimiter] is the delimiter to be used to separate each
/// line of the file into columns.
/// [lineDelimitier] is the delimiter to be used to separate each line.
/// [verbose] caused FileSort to log debug level information as it sorts.
///
class FileSort {
  final String _inputPath;
  final String _outputPath;
  final List<Column> _columns;
  final String _fieldDelimiter;
  final String _lineDelimiter;

  ///
  final bool verbose;
  int _maxColumn = -1;

  ///
  FileSort(this._inputPath, this._outputPath, this._columns,
      this._fieldDelimiter, this._lineDelimiter,
      {this.verbose = false}) {
    for (var column in _columns) {
      if (_maxColumn < column.ordinal) {
        _maxColumn = column.ordinal;
      }
    }
  }

  ///
  /// call this method to start the sort.
  void sort() {
    waitForEx<void>(_sort());
  }

  static const _mergeSize = 1000;
  Future _sort() async {
    var completer = Completer<void>();
    var instance = 0;
    var lineCount = _mergeSize;

    var phaseDirectory = Directory.systemTemp.createTempSync();

    var list = <_Line>[];

    var sentToPhase = false;

    var phaseFutures = <Future<void>>[];

    await File(_inputPath)
        .openRead()
        .map(utf8.decode)
        .transform(LineSplitter())
        .forEach((l) {
      list.add(_Line.fromString(_inputPath, l));
      lineCount--;

      if (lineCount == 0) {
        lineCount = _mergeSize;
        var phaseList = list;
        list = [];
        instance++;
        sentToPhase = true;
        var phaseFuture = Completer<void>();
        phaseFutures.add(phaseFuture.future);

        _savePhase(phaseDirectory, 1, instance, phaseList, _lineDelimiter);
        phaseFuture.complete(null);
      }
    });

    if (!sentToPhase) {
      _sortList(list);
      _replaceFileWithSortedList(list);
    } else {
      if (list.isNotEmpty && list.length < _mergeSize) {
        _savePhase(phaseDirectory, 1, ++instance, list, _lineDelimiter);
      }
      await Future.wait(phaseFutures);
      _mergeSort(phaseDirectory);
    }
    completer.complete();

    return completer.future;
  }

  void _replaceFileWithSortedList(List<_Line> sorted) {
    if (_inputPath == _outputPath) {
      var backup = '$_inputPath.bak';
      if (exists(backup)) {
        delete(backup);
      }
      d.move(_inputPath, backup);
      _saveSortedList(_outputPath, sorted, _lineDelimiter);
      d.delete('$_inputPath.bak');
    } else {
      _saveSortedList(_outputPath, sorted, _lineDelimiter);
    }
  }

  /// Performs an insitu sort of the passed list.
  void _sortList(List<_Line> list) {
    list.sort((lhs, rhs) {
      var lhsColumns = lhs.line.split(_fieldDelimiter);
      var rhsColumns = rhs.line.split(_fieldDelimiter);

      if (_maxColumn > lhsColumns.length) {
        throw InvalidArguments(
            'Line $lhs does not have enough columns. Expected ${_maxColumn}, found ${lhsColumns.length}');
      }

      if (_maxColumn > rhsColumns.length) {
        throw InvalidArguments(
            'Line $rhs does not have enough columns. Expected ${_maxColumn}, found ${lhsColumns.length}');
      }

      var result = 0;

      if (_maxColumn == 0) {
        // just compare the whole line.
        result =
            _columns[0]._comparator.compareTo(_columns[0], lhs.line, rhs.line);
      } else {
        // compare the defined columns
        for (var column in _columns) {
          var direction =
              column._sortDirection == SortDirection.ascending ? 1 : -1;

          result = column._comparator.compareTo(
                  column,
                  lhsColumns[column.ordinal - 1],
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

  void _savePhase(Directory phaseDirectory, int phase, int instance,
      List<_Line> list, String lineDelimiter) {
    var instanceFile =
        File(d.join(phaseDirectory.path, 'phase$phase-$instance'));

    _sortList(list);

    var lines = list.map((line) => line.line).toList();

    instanceFile.writeAsStringSync(lines.join(lineDelimiter) + lineDelimiter,
        flush: true);
  }

  void _saveSortedList(
      String filename, List<_Line> list, String lineDelimiter) async {
    var saveTo = d.FileSync(filename);

    saveTo.truncate();
    for (var line in list) {
      saveTo.append(line.line, newline: lineDelimiter);
    }
  }

  /// Expands an list of columns defined as per [Column.parse]
  /// into a list of [Column]s.
  ///
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

        var comparator = end._comparator;
        var sortDirection = end._sortDirection;

        var start = Column.parse(parts[0], ordinalOnly: true);
        start._comparator = comparator;
        start._sortDirection = sortDirection;

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
    var lines = <_Line>[];
    var files = d.find('*', root: phaseDirectory.path).toList();

    // Open and read the first line from each file.
    for (var file in files) {
      var fileSync = d.FileSync(file, fileMode: FileMode.read);
      lines.add(_Line(fileSync));
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

    if (_inputPath == _outputPath) {
      var backup = '$_inputPath.bak';
      if (exists(backup)) {
        delete(backup);
      }
      d.move(_inputPath, backup);
      d.move(mergedPath, _inputPath);
      d.delete(backup);
    } else {
      d.move(mergedPath, _outputPath);
    }
    d.deleteDir(phaseDirectory.path);
  }
}

class _Line {
  FileSync source;
  String sourcePath;
  String line;

  _Line(this.source) {
    sourcePath = source.path;
    line = source.readLine();
  }

  _Line.fromString(this.sourcePath, this.line);

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

  @override
  String toString() {
    return 'File: ${sourcePath} : Line: $line';
  }
}

/// Sets the sort direction.
enum SortDirection {
  ///
  ascending,

  ///
  descending
}

///
class CaseInsensitiveSort implements ColumnComparator {
  ///
  const CaseInsensitiveSort();
  @override
  int compareTo(Column column, String lhs, String rhs) {
    return lhs.toLowerCase().compareTo(rhs.toLowerCase());
  }
}

///
class CaseSensitiveSort implements ColumnComparator {
  ///
  const CaseSensitiveSort();
  @override
  int compareTo(Column column, String lhs, String rhs) {
    return lhs.compareTo(rhs);
  }
}

///
class NumericSort implements ColumnComparator {
  ///
  const NumericSort();
  @override
  int compareTo(Column column, String lhs, String rhs) {
    var numLhs = num.tryParse(lhs);
    if (numLhs == null) {
      throw FormatException(
          'Column ${column.ordinal} contained a non-numeric value.', lhs);
    }
    var numRhs = num.tryParse(rhs);

    if (numRhs == null) {
      throw FormatException(
          'Sort Column ${column.ordinal} contained a non-numeric value.', rhs);
    }

    return numLhs.compareTo(numRhs);
  }
}

///
class MonthSort implements ColumnComparator {
  ///
  const MonthSort();
  @override
  int compareTo(Column column, String lhs, String rhs) {
    var mLhs = toMonthNo(lhs);
    var mRhs = toMonthNo(rhs);
    return mLhs.compareTo(mRhs);
  }

  ///
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

///
// ignore: one_member_abstracts
abstract class ColumnComparator {
  ///
  int compareTo(Column column, String lhs, String rhs);
}

///
/// Defined a column to sort by for the FileSort
/// class.
class Column {
  static const _typeMap = {
    's': CaseInsensitiveSort(),
    'S': CaseSensitiveSort(),
    'n': NumericSort(),
    'm': MonthSort(),
  };
  static const _directionMap = {
    'a': SortDirection.ascending,
    'd': SortDirection.descending
  };

  @override
  String toString() {
    return 'ordinal: $ordinal, comparator: ${_comparator.runtimeType}, sortDirection: ${_sortDirection}';
  }

  /// [ordinal] is the column index using base 1
  /// An ordinal of 0 means that we are treating the entire
  /// line as a single column.
  int ordinal;
  ColumnComparator _comparator;
  SortDirection _sortDirection;

  /// [ordinal] the (base 1) index of the column.
  /// The [_comparator] we will used to compare
  /// to lines when sorting.
  /// The [_sortDirection] is either ascending or decending.
  ///
  Column(this.ordinal, this._comparator, this._sortDirection);

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
    var digits = _countDigits(column);

    ordinal = int.parse(column.substring(0, digits));

    if (ordinalOnly && digits < column.length) {
      throw InvalidArguments('Expected only a column no but found: $column');
    }

    var type = 's';

    if (column.length > digits) {
      type = column.substring(digits, digits + 1);
    }

    _comparator = _typeMap[type];

    if (_comparator == null) {
      throw InvalidArguments('The sort type $type is not valid');
    }

    var direction = 'a';

    if (column.length > digits + 1) {
      direction = column.substring(digits + 1, digits + 2);
    }
    _sortDirection = _directionMap[direction];

    if (_sortDirection == null) {
      throw InvalidArguments('The sort direction $direction is not valid');
    }
  }

  int _countDigits(String column) {
    var digits = 0;

    for (var i = 0; i < column.length; i++) {
      if (!_isDigit(column[i])) {
        break;
      }
      digits++;
    }
    return digits;
  }

  bool _isDigit(String c) {
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
