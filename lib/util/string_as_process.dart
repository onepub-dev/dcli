import 'package:dshell/commands/run.dart' as cmd;
import 'package:dshell/util/runnable_process.dart';

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
  ///
  /// ```dart
  /// 'zip regions.txt regions.zip'.run
  /// ```
  ///
  void get run => cmd.run(this);

  /// forEach
  /// Like run it allows you to execute a string as a command line
  /// application and then calls the supplied LineAction
  /// for each line output by the cli command.
  ///
  /// ```dart
  /// 'grep alabama regions.txt'.forEach((line) => print(line));
  /// ```
  ///
  void forEach(LineAction action) => cmd.run(this, action);

  List<String> get lines {
    List<String> lines = List();
    cmd.run(this, (line) => lines.add(line));

    return lines;
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
    RunnableProcess rhsRunnable = RunnableProcess(rhs);
    rhsRunnable.start();

    RunnableProcess lhsRunnable = RunnableProcess(this);
    lhsRunnable.start();

    return Pipe(lhsRunnable, rhsRunnable);
  }
}
