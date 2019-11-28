import 'package:dshell/util/progress.dart';
import 'package:dshell/util/runnable_process.dart';

import 'dshell_function.dart';

///
/// Runs the given cli command calling [lineAction]
/// for each line the cli command returns.
/// [lineAction] is called as the command runs rather than waiting
/// for the command to complete.
///
/// ```dart
/// "wc fred.txt".forEach((line) => print(line));
/// ```
///
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// If the command fails or returns a non-zero exitCode
/// Then a [RunCommand] exception will be thrown.
Progress run(String command, {Progress progress}) =>
    Run().run(command, progress: progress);

class Run extends DShellFunction {
  RunnableProcess runnable;

  /// returns the exitCode of the process that or command that was run.
  Progress run(String command, {Progress progress}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();
      runnable = RunnableProcess(command);
      runnable.start();
      runnable.processUntilExit((line) => forEach.addToStdout(line),
          (line) => forEach.addToStderr(line));
    } finally {
      forEach.close();
    }

    return forEach;
  }
}
