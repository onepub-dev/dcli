# Examples

## example.dart

Demonstrates a grab bag of dcli features.

```dart
#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  try {
    // Print the current working directory
    print('PWD: $pwd');
    echo('PWD: $pwd');

    print(green("Let's compose a sonet together"));
    var name = ask('Name of our poem:', validator: Ask.alpha);

    print(orange("'Let's keep it our secret"));
    var password = ask(red('Password:'),
        hidden: true,
        validator: Ask.all([Ask.alphaNumeric, Ask.lengthMin(12)]));

    print(red('your password is: $password'));

    var baseDir = 'poetry';

    // We could use cd, push and pop but that is considered bad
    // practice.
    // So we use explict paths becuase we are good people.
    var poetryForReviews = join(baseDir, 'forReview');

    // Create a directory to hold poems for review
    // creating  any needed parents.
    if (!exists(poetryForReviews)) {
      createDir(poetryForReviews, recursive: true);
    }

    // Creating a directory to hold our published work.
    var poetryPublished = join(baseDir, 'published');
    if (!exists(poetryPublished)) {
      createDir(poetryPublished, recursive: true);
    }

    // Create a self edifying poem.
    var poem = '$name.txt';

    // write a poem of such beauty it will mesmerise the beholder.
    var verse1 = '''
    A rose is a rose by any other name.
    But don't let its beauty bewilder you,
    as its tongue is sharp and it will surely tear you apart.
    Go not amongst the roses, for they will surely taunt your ever step
    and claw at your very flesh.''';

    var verse2 = '''
    Do not listen to the gardener, they are not your friend.
    The will speak with venom of the Aphids that suck the sap
    and praise the lady beetle that attack the poor Aphid.
    But know the truth, the Aphid is your friend, and the
    beetle your mortal enemy.
    The Aphid would bring down the fearful rose but that
    garish bettle will consume with glee the poor Aphid. 
    ''';

    var restingPlace = join(poetryForReviews, poem);

    // Write the verses to poem.txt
    // in the review directory.

    // write vs, truncating the file if required.
    restingPlace.write(verse1);
    restingPlace.append('');
    restingPlace.append(verse2);

    // take a moments beauty sleep to bask in our own
    // glory for a couple of seconds because we are worth it.
    sleep(2);

    echo('Find files matching *.txt');
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find('*.txt').toList()) {
      print(file);
    }

    // or use the forEach method which will
    // print each match as its found.
    echo('Print matches as we go');
    find('*.txt').forEach(print);

    print('');
    print('Please review this most gloreous work.');
    print('');

    // Review our good woork.
    cat(restingPlace);

    read(restingPlace, delim: '\r\n').forEach(print);

    // ask the user if we are ready to publish.
    // But we can't do this in a vscode debug session
    // so commenting it out for now.
    // a patch is comming for vscode.
    if (confirm('Publish:')) {
      // move to the published directory.
      move(restingPlace, poetryPublished);

      restingPlace = join(poetryPublished, poem);
      // Confirm that our poem arrived safely.
      if (exists(restingPlace)) {
        print('');
        print('Our joy has been published, for all to behold.');
        print('');
      }
    } else {
      print('What my prose is not good enough; you heathen.');
    }

    // Lets get a word count
    'wc $restingPlace'.forEach((line) => print('WC: $line'), stderr: print);

    print('');

    // Find each line in our poem that contains the word rose.
    'grep rose $restingPlace'.forEach((line) => print('Grep: $line'),
        stderr: (line) => [print(line)]);

    // lets do some pipeing and see the 3-5 lines
    ('head  -5 $restingPlace' | 'tail -n 3').forEach(print);

    // but the world doesn't deserve our work
    // so burn it all to hell.
    delete(restingPlace, ask: false);
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    // All errors are thrown as exceptions.
    print('An error occured: ${e.toString()}');
    e.printStackTrace();
  }
}

```

## kill_tomcat.dart

Searches for the a java process called tomcat and kills it. 

```dart
#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

void main() {
  // find all java processes
  var killed = false;
  'ps aux'.forEach((line) {
    if (line.contains('java') && line.contains('tomcat')) {
      var parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        var pidPart = parts[1];
        var pid = int.tryParse(pidPart) ?? -1;
        if (pid != -1) {
          print('Killing tomcat with pid=$pid');
          'kill -9 $pid'.run;
          killed = true;
        }
      }
    }
  });

  if (killed == false) {
    print('tomcat process not found.');
  }
}

```


## dshell.dart
A toy REPL shell to replace your bash command line in just 50 lines of dart.

```dart

#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

/// A toy REPL shell to replace your bash command line in just 50 lines of dart.
void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    var line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}

// Evaluate the users input
void evaluate(String command) {
  var parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
      break;
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
    case 'exit':
      exit(0);
      break;
    default:
      if (which(parts[0]).found) {
        command.start(nothrow: true, progress: Progress.print());
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
      break;
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*', root: pwd, recursive: false, types: [Find.file, Find.directory])
        .forEach((file) => print('  $file'));
  } else {
    for (var pattern in patterns) {
      find(pattern,
              root: pwd, recursive: false, types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
  }
}

```

## dsort.dart

Sort a file.

```dart
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/file_sort.dart';

/// dsort
///
/// dsort --field-delimiter=<FD> --linedelimiter=<LD> --key=<columns> --output output <file>
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
const String sortkeyOption = 'sortkey';
const String outputOption = 'output';

void main(List<String> args) {
  dsort(args);
}

void dsort(List<String> args) async {
  var columns = <Column>[];
  String fieldDelimiter;
  String lineDelimiter;
  String outputPath;
  bool verbose;

  var parser = ArgParser()
    ..addFlag('verbose', abbr: 'v', callback: (value) => verbose = value)
    ..addOption(fieldDelimiterOption,
        abbr: 'f',
        defaultsTo: ',',
        //ignore: avoid_types_on_closure_parameters
        callback: (String value) => fieldDelimiter = value)
    ..addOption(lineDelimiterOption,
        abbr: 'l',
        defaultsTo: '\n',
        //ignore: avoid_types_on_closure_parameters
        callback: (String value) => lineDelimiter = value)
    ..addMultiOption(sortkeyOption,
        abbr: 's',
        //ignore: avoid_types_on_closure_parameters
        callback: (List<String> values) =>
            columns.addAll(FileSort.expandColumns(values)))
    ..addOption(outputOption, abbr: 'o');

  var results = parser.parse(args);

  if (results.rest.length != 1) {
    usageError('Expected an input_file to sort.');
  }

  var inputPath = absolute(results.rest[0]);

  if (results[outputOption] != null) {
    outputPath = results[outputOption].toString();
  }
  outputPath ??= inputPath;

  outputPath = absolute(outputPath);

  if (columns.isEmpty) {
    /// if no columns defined we sort by the whole line.
    columns.add(Column(0, CaseInsensitiveSort(), SortDirection.ascending));
  }

  if (verbose) {
    print('Columns: ${columns.join("\n")}');
    print('Input File: $inputPath, Output File: $outputPath');
    print("Field Delimiter: '$fieldDelimiter'");
    print("Line Delimiter: '$lineDelimiter'");
  }

  if (!exists(inputPath)) {
    usageError('The input file $inputPath does not exist');
  }

  if (exists(outputPath) && outputPath != inputPath) {
    usageError(
        'The output_file $outputPath already exist. Delete the file and try again.');
  }

  var sort = FileSort(
      inputPath, outputPath, columns, fieldDelimiter, lineDelimiter,
      verbose: verbose);

  await sort.sort();
}

void usageError(String error) {
  print(red(error));
  print('');
  print('''
Example:

dsort --sortkey=1n unsorted.txt

Usage Details:

dsort --field-delimiter=<fd> --linedelimiter=<ld> --sortkey=<columns> --output=output_file <input_file>

  -f, --field-delimiter=<fd>     (defaults to ,)
  -l, --line-delimiter=<ld>      (defaults to \n)
  -s, --sortkey=<columns>        (defaults to 0) 
  -o, --output=<output>          (defaults to <file>)

  --field-delimiter
     defines the field delimiter for columns in the file
   
  --line-delimiter
     defines the line delimiter for the input file and the output file.
   
  --sortkey defines columns to sort on and how each column is sorted.
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

  --output
    Defines the file to write the sorted output to. If not provided then we do an insitu sort.

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


```

## which.dart

Implement the classic linux which command

```dart
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:args/args.dart';

/// which appname
void main(List<String> args) {
  var parser = ArgParser();
  parser..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false);

  var results = parser.parse(args);

  var verbose = results['verbose'] as bool;

  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  var command = results.rest[0];

  for (var path in PATH) {
    if (verbose) {
      print('Searching: ${canonicalize(path)}');
    }
    if (exists(join(path, command))) {
      print(red('Found at: ${canonicalize(join(path, command))}'));
    }
  }
}


```






For additional examples see the dcli_script project:

https://github.com/bsutton/dcli_scripts