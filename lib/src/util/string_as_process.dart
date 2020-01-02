import '../functions/run.dart' as cmd;
import 'runnable_process.dart';

import 'file_sync.dart';
import 'progress.dart';
import 'pipe.dart';

///
/// A set of String extensions that lets you
/// execute the contents of a string as a command line application.
///
extension StringAsProcess on String {
  /// run
  ///
  /// Allows you to execute the contents of a dart string as a
  /// command line appliation.
  /// Any output from the command is displayed on the console.
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.run
  /// ```
  ///
  /// See [forEach] to capture output to stdout and stderr
  ///     [toList] to capture stdout to [List<String>]
  void get run => cmd.run(this);

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
  /// See [run] if you don't care about capturing output
  ///     [list] to capture stdout as a String list.
  ///
  void forEach(LineAction stdout, {LineAction stderr}) =>
      cmd.run(this, progress: Progress(stdout, stderr: stderr));

  /// [toList] runs [this] as a cli process and
  /// returns any output written to stdout as
  /// a [List<String>].
  List<String> toList({Pattern lineDelimiter = '\n'}) {
    return cmd.run(this).toList();
  }

  /// operator |
  ///
  /// The classic bash style pipe operator.
  ///
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
    rhsRunnable.start();

    var lhsRunnable = RunnableProcess(this);
    lhsRunnable.start();

    return Pipe(lhsRunnable, rhsRunnable);
  }

  // Treat the [this]  as the name of a file and
  // write [line] to the file terminated by [newline].
  // [newline] defaults to '\n'.
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

  // Treat the [this]  as the name of a file
  // and append the [line] to it.
  // If [newline] is true add a newline after the line.
  void append(String line, {String newline = '\n'}) {
    var sink = FileSync(this);
    sink.append(line, newline: newline);
    sink.close();
  }
}
