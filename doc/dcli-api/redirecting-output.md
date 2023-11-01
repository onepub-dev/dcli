# Redirecting output

This page talks about redirecting output from a process (app) that you run using one of the DCLI commands such as 'start'.

If you are not familiar with concepts such as stdout and stdin then have a read of our primer on [stdin/stdout/stderr](../dart-basics/stdin-stdout-stderr.md).

If you have used bash then you may be familiar with the bash redirect operator '>'.  DCli also allows you to redirect output and the most common method we use is a 'Progress'.

So let's have a look at how we use Progress to redirect the output of the 'start' command.

By default, the `start` command prints all output (stdout and stderr) to the console. But what if we want to redirect stdout to a log file?

Passing a Progress to the 'start' command allows you to redirect both stdout and stderr independently.

### redirect stdout to a log

```dart
import 'package:dcli/dcli.dart';

void main() {


import 'package:dcli/dcli.dart';

void main() {

  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(progress: Progress(pathToLog.append));

  print('Displaying the log file');
  cat(pathToLog);
}

```

### Redirect stderr

Redirect stderr to a log whilst still printing to stdout to the console

```dart
void main() {
  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(progress: Progress( print, stderr: (line) => pathToLog.append));

  print('Displaying the log file');
  cat(pathToLog);
}
```

### long hand

The above two examples use tear-offs which make it a little hard to understand what is going on so let's do it the long way:

```dart
void main3() {
  const pathToLog = 'log.txt';
  print('running ls');
  'ls *'.start(
      progress: Progress((line) {
      // the first positional argument to Progress is a lambda which is
      /// called each time a line is written to stdout
    print(line);
  }, stderr: (line) {
     /// the second named argument to Progress is a lambda which is
     /// called each time a line is written to stderr
    pathToLog.append(line);
  }));

  print('Displaying the log file');
  cat(pathToLog);
}

```

## dealing with errors

When a console app writes to stderr it may also exit with a non-zero exit code.

By default, the DCli 'start' command will throw an exception if an app exits with any value but zero.

If you are looking to process the output from stderr in order to take some action when an error occurs, then you need to suppress DCli's default behaviour of throwing an exception.&#x20;

In this case, you need to pass the 'nothrow' argument to start.

```dart

void main() {
  final errors = <String>[];

  final result = 'ls /fred'.start(
      /// stop the start command from throwing if 'ls' returns a non-zero exit code
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
```

