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
///
/// The [nothrow] argument is EXPERIMENTAL
Progress run(String command,
        {Progress progress, bool runInShell = false, bool nothrow = false}) =>
    Run().run(command,
        progress: progress, runInShell: runInShell, nothrow: nothrow);

///
///
Progress start(String command,
        {Progress progress,
        bool runInShell = false,
        bool detached = false,
        bool terminal = false,
        String workingDirectory}) =>
    Run().start(command,
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        workingDirectory: workingDirectory);

class Run extends DShellFunction {
  RunnableProcess runnable;

  /// returns the exitCode of the process that was run.
  Progress run(String command,
      {Progress progress, bool runInShell = false, bool nothrow}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();
      runnable = RunnableProcess(command);
      runnable.start(runInShell: runInShell);
      runnable.processUntilExit(forEach, nothrow: nothrow);
    } finally {
      forEach.close();
    }
    return forEach;
  }

  Progress start(String command,
      {Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory,
      bool terminal}) {
    Progress forEach;

    try {
      forEach = progress ??
          Progress((line) => print(line), stderr: (line) => printerr(line));
      var runnable =
          RunnableProcess(command, workingDirectory: workingDirectory);
      runnable.start(
          runInShell: runInShell, detached: detached, terminal: terminal);
      if (detached == false) {
        if (terminal == false) {
          runnable.processUntilExit(forEach);
        } else {
          runnable.waitForExit();
        }
      }
    } finally {
      forEach.close();
    }
    return forEach;
  }
}
