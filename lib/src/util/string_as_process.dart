import 'dart:async';

import '../functions/run.dart' as cmd;
import 'file_sync.dart';

import 'parser.dart';
import 'pipe.dart';
import 'progress.dart';

import 'runnable_process.dart';

///
/// A set of String extensions that lets you
/// execute the contents of a string as a command line application.
///
/// e.g.
/// 'tail /var/log/syslog'.run;
///
extension StringAsProcess on String {
  /// Allows you to execute the contents of a dart string as a
  /// command line appliation.
  /// Any output from the command  (stderr and stdout) is displayed
  ///  on the console.
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.run;
  /// ```
  ///
  /// If you need to pass an argument to your application that contains
  /// spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run;
  ///```
  ///
  /// Any environment variables you set via env['xxx'] will be passed
  /// to the new process.
  ///
  /// Linux:
  /// DCli performs glob (wildcard) expansion on command arguments
  /// if it contains any one
  /// of `*, [ or ?`  unless the argument is quoted.
  /// DCli uses the dart package Glob (https://pub.dev/packages/glob) to do the glob expansion.
  ///
  /// The following command will have the argument containing the
  /// wild card *.dart expanded to
  /// the list of files, in the current directory, that match the
  ///  pattern *.dart.
  ///
  /// If no files match the pattern then the pattern will be passed
  /// to the command unchanged:
  ///
  /// ```dart
  /// 'ls *.dart'.run;
  /// ```
  ///
  /// If you add quotes around the wild card then it will not be expanded:
  ///
  /// ```dart
  /// 'find . -name "*.dart"'.run;
  /// ```
  ///
  /// Windows:
  ///  On windows Glob expansion is suppressed as both Command and Powershell
  /// don't expand
  ///  globs.
  ///
  ///
  /// See [forEach] to capture output to stdout and stderr
  ///     [toList] to capture stdout  and stderr to [List<String>]
  ///     [start] - for more control over how the sub process is started.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [parser] - returns a parser with the captured output ready
  /// to be interpreted
  ///                as one of several file types.
  void get run {
    cmd.start(this,
        terminal: true, progress: Progress(print, stderr: printerr));
  }

  /// shell
  /// Runs the given string as a command in the OS shell.
  ///
  /// Allows you to execute the contents of a dart string as a
  /// command line appliation within an OS shell (e.g. bash).
  /// The application is run as a fully attached child process.
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// Any output from the command is displayed on the console.
  ///
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.shell;
  /// ```
  ///
  /// If you need to pass an argument to your application that contains
  ///  spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.shell;
  ///```
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// See [forEach] to capture output to stdout and stderr
  ///     [toList] to capture stdout and stderr to [List<String>]
  ///     [firstLine] - returns just the first line written to stdout.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [parser] - returns a parser with the captured output ready
  ///  to be interpreted
  ///                as one of several file types.
  @Deprecated('use start(runInShell: true)')
  void get shell => cmd.run(this, runInShell: true);

  /// Runs the contents of this String as a command line application.
  ///
  /// Any output from the command (stderr and stdout) is displayed
  ///  on the console.
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// Use [runInShell] if the command needs to be run inside
  /// an OS shell (e.g bash).
  ///    [runInShell] defaults to false.
  ///
  /// Use [detached] to start the application as a fully
  /// detached subprocess.
  ///
  /// You cannot process output from a detached process
  /// and it will continuing running after the dcli process
  /// exits. The detached process is also detached from the console
  /// and as such no output from the process will be visible.
  ///
  /// Use [terminal] = true when you need the process attached to a terminal.
  /// When attached to a terminal you will not be able to process
  /// any of the output from the child process.
  /// (e.g. forEach won't work.)
  /// You need to set [terminal]=true if you want the called application
  /// to be able to interact with the user (ask for input) or if you
  /// want the application to be able to output ansi codes such
  /// as colours and cursor movement or detect the window size.
  ///
  /// You can NOT use [terminal] and [detached] at the same time.
  ///
  /// Use [workingDirectory] to specify the directory the process should
  /// be run from.
  ///
  /// If you need to run a command with escalated privileged then set the
  /// [privileged]
  /// argument to true. On Linux this equates to using the sudo command.
  /// The advantage of using the 'privileged' option is that it will first
  /// check if you are
  /// already running in a privileged environment. This is extremly useful
  ///  if you
  /// are running in the likes of a Docker container that doesn't implement
  /// sudo but
  /// in which you are already running as root.
  ///
  /// Any environment variables you set via env['xxx'] will be passed to the
  ///  new process.
  ///
  ///
  /// If you need to pass an argument to your application that contains spaces
  /// then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.start(terminal: true);
  ///```
  ///
  /// See  [run] if you just need to run a process with all the defaults.
  ///      [forEach] to capture output to stdout and stderr
  ///      [toList] to capture stdout and stderr to [List<String>]
  ///      [firstLine] - returns just the first line written to stdout
  ///  or stderr.
  ///      [lastLine] - returns just the last line written to stdout or stderr.
  ///      [parser] - returns a parser with the captured output ready
  /// to be interpreted as one of several file types.
  Progress start({
    Progress? progress,
    bool runInShell = false,
    bool detached = false,
    bool terminal = false,
    bool nothrow = false,
    bool privileged = false,
    String? workingDirectory,
  }) =>
      cmd.start(this,
          progress: progress ?? Progress(print, stderr: printerr),
          runInShell: runInShell,
          detached: detached,
          terminal: terminal,
          nothrow: nothrow,
          privileged: privileged,
          workingDirectory: workingDirectory);

  /// forEach runs the contents of this String as a command line
  /// application.
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// Output from the command can be captured by
  /// providing handlers for stdout and stderr.
  ///
  /// ```dart
  /// // Capture output to stdout and print it.
  /// 'grep alabama regions.txt'.forEach((line) => print(line));
  ///
  /// // capture output to stdout and stderr and print them.
  /// 'grep alabama regions.txt'.forEach((line) => print(line)
  ///     , stderr: (line) => print(line));
  /// ```
  ///
  /// Any environment variables you set via env['xxx'] will be passed
  ///  to the new process.
  ///
  /// If you need to pass an argument to your application that contains
  /// spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run;
  ///```
  ///
  /// See [run] if you don't care about capturing output
  ///     [toList] to capture stdout and stderr as a String list.
  ///     [start] - if you need to run a detached sub process.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [parser] - returns a parser with the captured output ready
  ///  to be interpreted
  ///                as one of several file types.
  void forEach(LineAction stdout,
          {LineAction stderr = _noOpAction, bool runInShell = false}) =>
      cmd.start(this,
          progress: Progress(stdout, stderr: stderr), runInShell: runInShell);

  /// [toList] runs the contents of this String as a cli command and
  /// returns any output written to stdout and stderr as
  /// a [List<String>].
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// The [skipLines] argument tells [toList] to not return the first
  /// [skipLines] lines. This is useful if a command outputs a heading
  /// and you want to skip over the heading.
  ///
  /// If [runInShell] is true (defaults to false) then the command will
  /// be run in a shell. This may be required if you are trying to run
  /// a command that is builtin to the shell.
  ///
  /// If the command completes with a non-zero exit code then a
  /// RunException is thrown. The RunException includes the exit code
  /// and the cause contains all of the output the command wrote to
  /// stdout and stderr before it exited.
  ///
  /// Any environment variables you set via env['xxx'] will be passed
  ///  to the new process.
  ///
  ///EXPERIMENTAL argument.
  /// If [nothrow] is set to true then an exception will not be thrown on
  /// a non-zero exit code. Many applications output to stdout/stderr
  /// to display an error message when a non-zero exit code is returned.
  /// If you need to process these error messages then pass [nothrow:true].
  /// The default for nothrow is false - i.e. we throw an exception on a
  /// non-zero exitCode.
  ///
  /// ```dart
  /// List<String> logLines = 'tail -n 10 /var/log/syslog'.toList();
  /// ```
  ///
  /// See [forEach] to capture output to stdout and stderr interactively
  ///     [run] to run the application without capturing its output
  ///     [start] - to run the process fully detached.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [parser] - returns a parser with the captured output ready
  /// to be interpreted
  ///                as one of several file types.

  List<String> toList(
      {bool runInShell = false, int skipLines = 0, bool nothrow = false}) {
    final progress = cmd.start(this,
        runInShell: runInShell, progress: Progress.capture(), nothrow: nothrow);

    return progress.lines.sublist(skipLines);
  }

  /// [parser] runs the contents of this String as a cli command line
  ///  reading all of the
  /// returned data and then passes the read lines to a [Parser]
  /// to be decoded as a specific file type.
  ///
  /// EXPERIMENTAL: we may rework the data structures the parser returns.
  ///
  /// DCli performs Glob expansion on command line arguments.
  /// See [run] for details.
  ///
  /// If [runInShell] is true (defaults to false) then the command will
  /// be run in a shell. This may be required if you are trying to run
  /// a command that is builtin to the shell.
  ///
  ///
  /// If the command returns a non-zero value an exception will
  /// be thrown.
  ///
  /// ```dart
  ///  var json =
  ///    'wget -qO- https://jsonplaceholder.typicode.com/todos/1'.parser.jsonDecode();
  ///
  ///   print('Title: ${json["title"]}');
  /// ```
  ///
  /// See [forEach] to capture output to stdout and stderr interactively
  ///     [run] to run the application without capturing its output
  ///     [start] - to run the process fully detached.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [toList] -  returns a lines written to stdout and stderr as a list.

  Parser parser({bool runInShell = false}) {
    final lines = toList(runInShell: runInShell);

    return Parser(lines);
  }

  /// [firstLine] treats the contents of this String as a cli process and
  /// returns the first line written to stdout or stderr as
  /// a [String].
  /// Returns null if no lines are returned.
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// e.g.
  /// ```
  /// 'tail -n 10 /var/log/syslog'.firstLine;
  /// ```
  ///
  /// See [forEach] to capture output to stdout and stderr interactively
  ///     [run] to run the application without capturing its output
  ///     [start] - to run the process fully detached.
  ///     [toList] - returns a lines written to stdout and stderr as a list.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///     [parser] - returns a parser with the captured output ready
  /// to be interpreted
  ///                as one of several file types.
  String? get firstLine {
    final lines = toList();

    String? line;
    if (lines.isNotEmpty) {
      line = lines[0];
    }

    return line;
  }

  /// [lastLine] runs the contents of this String as a cli process and
  /// returns the last line written to stdout or stderr as
  /// a [String].
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// e.g.
  /// ```
  /// 'tail -n 10 /var/log/syslog'.lastLine;
  /// ```
  ///
  /// NOTE: the current implementation is not efficient as it
  /// reads every line from the file rather than reading from the
  /// end backwards.
  ///
  /// See [forEach] to capture output to stdout and stderr interactively
  ///     [run] to run the application without capturing its output
  ///     [start] - to run the process fully detached.
  ///     [toList] - returns a lines written to stdout and stderr as a list.
  ///     [firstLine] - returns just the first line written to stdout.
  ///     [parser] - returns a parser with the captured output ready
  ///  to be interpreted
  ///                as one of several file types.
  String? get lastLine {
    String? lastLine;

    forEach((line) => lastLine = line, stderr: (line) => lastLine = line);

    return lastLine;
  }

  /// The classic bash style pipe operator.
  /// Allows you to chain mulitple processes by piping the output
  /// of the left hand process to the input of the right hand process.
  ///
  /// DCli performs Glob expansion on command arguments. See [run] for details.
  ///
  /// The following command calls:
  ///  - tail on syslog
  ///  - we pipe the result to head
  ///  - head returns the top 5 lines
  ///  - we pipe the 5 lines to tail
  ///  - tail returns the last 2 of those 5 line
  ///  - We are then back in dart world with the forEach where we
  /// print the 2 lines.
  ///
  /// ``` dart
  /// 'tail /var/log/syslog' | 'head -n 5' | 'tail -n 2'.forEach((line) => print(line));
  /// ```
  Pipe operator |(String rhs) {
    final rhsRunnable = RunnableProcess.fromCommandLine(rhs)
      ..start(waitForStart: false);

    final lhsRunnable = RunnableProcess.fromCommandLine(this)
      ..start(waitForStart: false);

    return Pipe(lhsRunnable, rhsRunnable);
  }

  // // /// Experiemental - DO NOT USE
  // // Stream<String> get stream {
  // //   var lhsRunnable = RunnableProcess.fromCommandLine(this);
  // //   lhsRunnable.start(waitForStart: false);
  // //   return lhsRunnable.stream;
  // // }
  // Stream<String> stream({
  //   bool runInShell = false,
  //   bool nothrow = false,
  //   String workingDirectory,
  // }) {
  //   var runnable = RunnableProcess.fromCommandLine(this,
  //       workingDirectory: workingDirectory);
  //   runnable.run(runInShell: runInShell, nothrow: nothrow, terminal: false);
  //   return runnable.stream.transform(utf8.decoder);
  // }
  /// Experiemental - allows you to get a stream of the output written by the
  /// called process.
  Stream<String> stream(
      {bool runInShell = false,
      String? workingDirectory,
      bool nothrow = false,
      bool includeStderr = true}) {
    final progress = Progress.stream(includeStderr: includeStderr);

    cmd.startStreaming(this,
        runInShell: runInShell,
        progress: progress,
        workingDirectory: workingDirectory,
        nothrow: nothrow);

    return progress.stream;
  }

  /// Experiemental - DO NOT USE
  Sink get sink {
    final lhsRunnable = RunnableProcess.fromCommandLine(this)
      ..start(waitForStart: false);
    return lhsRunnable.sink;
  }

  /// Experiemental - DO NOT USE
  RunnableProcess get process {
    final process = RunnableProcess.fromCommandLine(this)
      ..start(waitForStart: false);

    return process;
  } // Treat the [this]  as the name of a file and

  /// Truncates and Writes [line] to the file terminated by [newline].
  /// [newline] defaults to '\n'.
  ///
  /// e.g.
  /// ```dart
  /// '/tmp/log'.write('Start of Log')
  /// ```
  ///
  /// See [truncate] and [append].
  void write(String line, {String newline = '\n'}) {
    FileSync(this)
      ..write(line, newline: newline)
      ..close();
  }

  /// Truncates a file by setting its length to zero.
  ///
  /// e.g.
  /// ```dart
  /// '/tmp/log'.truncate()
  /// '/tmp/log'.append('Start of Log')
  /// ```
  /// See [write] and [append]
  void truncate() {
    FileSync(this).truncate();
  }

  /// Treat the contents of 'this' String  as the name of a file
  /// and appends [line] to the file.
  /// [newline] specifies the line termination character.
  /// If you don't want a newline appended then pass an empty
  /// string to [newline].
  /// [newline] defaults to '\n'.
  ///
  /// e.g.
  /// ```dart
  /// '.bashrc'.append('export FRED=ONE');
  /// ```
  /// See [write] and [truncate]
  void append(String line, {String newline = '\n'}) {
    FileSync(this) // , fileMode: FileMode.append)
      ..append(line, newline: newline)
      ..close();
  }
}

void _noOpAction(String line) {}
