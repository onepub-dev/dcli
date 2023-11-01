# Redirecting output

This page talks about redirecting output from a process (app) that you run using one of the DCLI commands such as 'start'.

If you are not familiar with concepts such as stdout and stdin then have a read of our primer on [stdin/stdout/stderr](../dart-basics/stdin-stdout-stderr.md).

If you have used bash then you may be familiar with the bash redirect operator '>'.  DCli also allows you to redirect output and the most common method we use is a 'Progress'.

So let's have a look at how we use Progress to redirect the output of the 'start' command.

By default, the `start` command prints all output to the console. But what if we want to redirect stdout to a log file.&#x20;

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
