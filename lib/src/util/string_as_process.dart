import '../functions/run.dart' as cmd;
import 'runnable_process.dart';

import 'file_sync.dart';
import 'progress.dart';
import 'pipe.dart';

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
  /// Any output from the command is displayed on the console.
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.run
  /// ```
  ///
  /// If you need to pass an argument to your application that contains spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run
  ///```
  ///
  /// See [forEach] to capture output to stdout and stderr
  ///     [toList] to capture stdout  and stderr to [List<String>]
  ///     [start] - for more control over how the sub process is started.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  void get run {
    cmd.run(this,
        progress:
            Progress((line) => print(line), stderr: (line) => printerr(line)));
  }

  /// shell
  /// Runs the given string as a command in the OS shell.
  ///
  /// Allows you to execute the contents of a dart string as a
  /// command line appliation within an OS shell (e.g. bash).
  /// The application is run as a fully attached child process.
  ///
  /// Any output from the command is displayed on the console.
  ///
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.run
  /// ```
  ///
  /// If you need to pass an argument to your application that contains spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run
  ///```
  ///
  /// See [forEach] to capture output to stdout and stderr
  ///     [toList] to capture stdout and stderr to [List<String>]
  ///     [firstLine] - returns just the first line written to stdout.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  ///
  @Deprecated('use start(runInShell: true)')
  void get shell => cmd.run(this, runInShell: true);

  /// Runs the String [this] as a command line application.
  /// Use [runInShell] if the command needs to be run inside
  /// an OS shell (bash, cmd...).
  ///    [runInShell] defaults to false.
  /// Use [detached] to start the application as a fully
  /// detached subprocess.
  /// Use [workingDirectory] to specify the directory the process should
  /// be run from.
  /// You cannot process output from a detached process
  /// and it will continuing running after the dshell process
  /// exits. The detached process is also detached from the console
  /// and as such no output from the process will be visible.
  ///
  ///
  /// If you need to pass an argument to your application that contains spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run;
  ///```
  ///
  /// See  [run] if you just need to run a process with all the defaults.
  ///      [forEach] to capture output to stdout and stderr
  ///      [toList] to capture stdout and stderr to [List<String>]
  ///      [firstLine] - returns just the first line written to stdout or stderr.
  ///      [lastLine] - returns just the last line written to stdout or stderr.
  ///
  void start(
      {Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory}) {
    cmd.start(this,
        progress:
            Progress((line) => print(line), stderr: (line) => printerr(line)),
        runInShell: runInShell,
        detached: detached,
        workingDirectory: workingDirectory);
  }

  /// forEach runs the String [this] as a command line
  /// application.
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
  ///
  /// If you need to pass an argument to your application that contains spaces then use nested quotes:
  ///e.g.
  ///  ```dart
  ///  'wc "fred nurk.text"'.run
  ///```
  ///
  /// See [run] if you don't care about capturing output
  ///     [list] to capture stdout as a String list.
  ///     [start] - if you need to run a detached sub process.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  void forEach(LineAction stdout,
          {LineAction stderr, bool runInShell = false}) =>
      cmd.run(this,
          progress: Progress(stdout, stderr: stderr), runInShell: runInShell);

  /// [toList] runs [this] String as a cli process and
  /// returns any output written to stdout and stderr as
  /// a [List<String>].
  ///
  /// ```dart
  /// var logLines = 'tail -n 10 /var/log/syslog'.toList();
  /// ```
  ///
  /// Note: [toList] does NOT capture output to stderr.
  /// See [forEach] to capture output to stdout and stderr interactively
  ///     [run] to run the application without capturing its output
  ///     [start] - to run the process fully detached.
  ///     [firstLine] - returns just the first line written to stdout or stderr.
  ///     [lastLine] - returns just the last line written to stdout or stderr.
  List<String> toList({bool runInShell = false}) {
    return cmd.run(this, runInShell: runInShell).toList();
  }

  /// [firstLine] treats the String [this] as a cli process and
  /// returns the first line written to stdout or stderr as
  /// a [String].
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
  String get firstLine {
    var lines = toList();

    String line;
    if (lines.isNotEmpty) {
      line = lines[0];
    }

    return line;
  }

  /// [lastLine] runs [this] as a cli process and
  /// returns the last line written to stdout or stderr as
  /// a [String].
  ///
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
  String get lastLine {
    String lastLine;

    forEach((line) => lastLine = line, stderr: (line) => lastLine = line);

    return lastLine;
  }

  /// The classic bash style pipe operator.
  /// Allows you to chain mulitple processes by piping the output
  /// of the left hand process to the input of the right hand process.
  ///
  /// The following command calls:
  ///  - tail on syslog
  ///  - we pipe the result to head
  ///  - head returns the top 5 lines
  ///  - we pipe the 5 lines to tail
  ///  - tail returns the last 2 of those 5 line
  ///  - We are then back in dart world with the forEach where we print the 2 lines.
  ///
  /// ``` dart
  /// 'tail /var/log/syslog' | 'head -n 5' | 'tail -n 2'.forEach((line) => print(line));
  /// ```
  Pipe operator |(String rhs) {
    var rhsRunnable = RunnableProcess(rhs);
    rhsRunnable.start(waitForStart: false);

    var lhsRunnable = RunnableProcess(this);
    lhsRunnable.start(waitForStart: false);

    return Pipe(lhsRunnable, rhsRunnable);
  }

  /// Experiemental - DO NOT USE
  Stream get stream {
    var lhsRunnable = RunnableProcess(this);
    lhsRunnable.start(waitForStart: false);
    return lhsRunnable.stream;
  }

  /// Experiemental - DO NOT USE
  Sink get sink {
    var lhsRunnable = RunnableProcess(this);
    lhsRunnable.start(waitForStart: false);
    return lhsRunnable.sink;
  }

  /// Experiemental - DO NOT USE
  RunnableProcess get process {
    var process = RunnableProcess(this);
    process.start(waitForStart: false);

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
  /// See [append] appends a line to an existing file.
  void write(String line, {String newline = '\n'}) {
    var sink = FileSync(this);
    sink.write(line, newline: newline);
    sink.close();
  }

  /// Truncates a file by setting its length to zero.
  void truncate() {
    var sink = FileSync(this);
    sink.truncate();
  }

  /// Treat [this] String  as the name of a file
  /// and append [line] to the file.
  /// If [newline] is true add a newline after the line.
  ///
  /// e.g.
  /// ```dart
  /// '.bashrc'.append('export FRED=ONE');
  /// ```
  ///
  void append(String line, {String newline = '\n'}) {
    var sink = FileSync(this);
    sink.append(line, newline: newline);
    sink.close();
  }
}
