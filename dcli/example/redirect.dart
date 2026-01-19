// example mains.
// ignore_for_file: unnecessary_lambdas, unreachable_from_main

import 'package:dcli/dcli.dart';

/// redirect stdout to a log file
/// @Throwing(ArgumentError)
/// @Throwing(CatException)
void main1() {
  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(progress: Progress(pathToLog.append));

  print('Displaying the log file');
  cat(pathToLog);
}

/// redirect stderr to a log file whilst print stdout to the console
/// @Throwing(ArgumentError)
/// @Throwing(CatException)
void main2() {
  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(progress: Progress(print, stderr: (line) => pathToLog.append));

  print('Displaying the log file');
  cat(pathToLog);
}

/// redirect stderr to a log file whilst print stdout to the console
/// without using tearoffs.
/// @Throwing(ArgumentError)
/// @Throwing(CatException)
void main3() {
  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(
      progress: Progress((line) {
    print(line);
  }, stderr: (line) {
    pathToLog.append(line);
  }));

  print('Displaying the log file');
  cat(pathToLog);
}

/// suppress stdout and redirect stderr to a list and process the output
void main() {
  final errors = <String>[];

  final result = 'ls /fred'.start(

      /// stop the start command from throwing if 'ls'
      /// returns non-zero exit code
      nothrow: true,
      progress: Progress((line) {
        // do nothing, so stdout is suppressed
      }, stderr: (line) {
        // add errors to the [errors] list
        errors.add(line);
      }));

  /// non-zero exit code means we have a problem.
  if (result.exitCode != 0) {
    if (errors[0].contains('No such file')) {
      printerr("The path passed to `ls` doesn't exist");
    }
  }
}
