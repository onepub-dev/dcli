import '../util/progress.dart';
import '../util/runnable_process.dart';

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
Progress run(String command, {Progress progress, bool runInShell = false}) =>
    Run().run(command, progress: progress, runInShell: runInShell);

class Run extends DShellFunction {
  RunnableProcess runnable;

  /// returns the exitCode of the process that was run.
  Progress run(String command, {Progress progress, bool runInShell = false}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();
      runnable = RunnableProcess(command);
      runnable.start(runInShell: runInShell);
      runnable.processUntilExit(forEach);
    } finally {
      forEach.close();
    }
    return forEach;
  }
}
