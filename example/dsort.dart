#! /usr/bin/env dshell
import 'dart:io';
import 'package:args/args.dart';
import 'package:dshell/dshell.dart';

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
/// dsort -fd=, -ld=\n --sortkey=1nd,2,3sd,1-7nd unsorted.txt
///
///

const String fieldDelimiterOption = 'field-delimiter';
const String lineDelimiterOption = 'line-delimiter';
const String sortkey = 'sortkey';

void main(List<String> args) async {
  var columns = <Column>[];
  String fieldDelimiter;
  String lineDelimiter;

  var parser = ArgParser()
    ..addOption(fieldDelimiterOption,
        abbr: 'f',
        defaultsTo: ',',
        callback: (String value) => fieldDelimiter = value)
    ..addOption(lineDelimiterOption, abbr: 'l', defaultsTo: '\n', help: 'xxx')
    ..addMultiOption(sortkey,
        abbr: 's',
        callback: (List<String> values) =>
            columns.addAll(FileSort.expandColumns(values)));

  var results = parser.parse(args);

  if (results.rest.length != 1) {
    usageError('Expected a file to sort.');
  }

  var filename = results.rest[0];

  var sort = FileSort(filename, columns, fieldDelimiter, lineDelimiter);

  await sort.sort();
}

void usageError(String error) {
  print(red(error));
  print('');
  print('''
dsort --field-delimiter=<fd> --linedelimiter=<ld> --sortkey=<columns> file

  -f, --field-delimiter=<fd>     (defaults to ,)
  -l, --line-delimiter=<ld>      (defaults to \n)
  -s, --sortkey=<columns>        (defaults to 0) 

 Define the columns to sort on.
 columns=<column-range>[<type>][<direction>],<columns>
 column-range=[<column>|<column>-<column>]
 column=int

 e.g. --sortkey=1 
    --sortkey=1,2-5,3

 Define the sort type for a <column-range>
 type=<s|n|m>
 s - case sensitive string sort - the default
 S - case insensitive string sort
 n - numeric sort
 m - month name sort

 e.g. --sortkey=1s
     --sortkey=1s,2-5n,3m

 Define the sort direction for a <column-range>
 [direction]=<a|d>
 a - ascending - the default
 d - descending

 e.g. --sortkey=1sd
     --sortkey=1sd,2-5na,3md

${green("Examples:")}
 String sort, ascending, sort using the whole line
 ${green("dsort unsorted.txt")}

 Numeric sort, desending on the first column only, using the default column delimiter ','
 ${green("dsort --sortkey=1nd unsorted.txt")}

 Descending, Numeric sort on col 1, 
   then Ascending string sort on col 2, 
  then Descending Case Sensitive String sort on col 3, 
  then Descending numeric sort on cols 5-7 inclusive
  using the column delimter ':'
 ${green("dsort -f=: --sortkey=1nd,2,3Sd,5-7nd unsorted.txt")}
''');

  exit(-1);
}
