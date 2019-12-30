/// dsort
///
/// dsort --field-delimiter=<FD> --linedelimiter=<LD> --key=<columns> file
///
/// <columns>=1[type][direction],3,7,1-7
/// <type>=<s|n|m>
/// s - case sensitive string sort - the default
/// S - case insensitive string sort
/// n - numeric sort
/// m - month name sort
///
/// [direction]=<a|d>
/// a - ascending - the default
/// d - descending
///
/// e.g.
///
/// dsort -fd=, -ld=\n --sortKey=1nd,2,3sd,1-7nd unsorted.txt
///
///

import 'package:args/args.dart';
import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/util/file_sort.dart';

const String fieldDelimiterOption = 'field-delimiter';
const String lineDelimiterOption = 'line-delimiter';
const String sortKey = 'sortKey';

void main(List<String> args) async {
  var columns = <Column>[];
  String fieldDelimiter;
  String lineDelimiter;

  var parser = ArgParser()
    ..addOption(fieldDelimiterOption,
        abbr: 'fd',
        defaultsTo: ',',
        callback: (String value) => fieldDelimiter = value)
    ..addOption(lineDelimiterOption, abbr: 'ld', defaultsTo: '\n')
    ..addMultiOption(sortKey,
        abbr: 'sk',
        callback: (List<String> values) =>
            columns.addAll(FileSort.expandColumns(values)));

  var results = parser.parse(args);

  if (results.rest.length != 1) {
    throw InvalidArguments('Expected a filename to sort');
  }

  var filename = results.rest[0];

  var sort = FileSort(filename, columns, fieldDelimiter, lineDelimiter);

  await sort.sort();
}
