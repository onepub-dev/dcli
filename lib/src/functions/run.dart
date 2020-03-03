import '../util/progress.dart';
import '../util/runnable_process.dart';

import 'dshell_function.dart';

///
/// Runs the given cli [commandline] returning a [Progress]
/// which can be used to process the output from the command
/// once the command has completed.
/// This method isn't suitable for commands that output large
/// quantities of data as that data must be stored in an in memory
/// stream until it can be processed after the command completes.
///
/// See: [start] or [startCommandLine] for methods that allow you to
/// process data as it is generated.
///
///
/// ```dart
/// "wc fred.txt".forEach((line) => print(line));
/// ```
///
/// DShell performs glob (wildcard) expansion on command arguments if it contains any one
/// of *, [ or ?  unless the argument is quoted.
/// DShell uses the dart package Glob (https://pub.dev/packages/glob) to do the glob expansion.
///
/// The following command will have the argument containing the wild card *.dart expanded to
/// the list of files, in the current directory, that match the pattern *.dart. If no files match the pattern then the pattern
/// will be passed to the command unchanged:
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
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// If the command fails or returns a non-zero exitCode
/// Then a [RunCommand] exception will be thrown.
///
/// The [nothrow] argument is EXPERIMENTAL
Progress run(String commandLine,
        {Progress progress, bool runInShell = false, bool nothrow = false}) =>
    Run().run(commandLine,
        progress: progress, runInShell: runInShell, nothrow: nothrow);

/// Allows you to execute a command by passing a [command]
/// and a list of args in [args].
///
/// DShell performs Glob expansion on command arguments. See [run] for details.
///
Progress start(String command, List<String> args,
        {Progress progress,
        bool runInShell = false,
        bool detached = false,
        bool terminal = false,
        String workingDirectory}) =>
    Run().fromCommandArgs(command,
        args: args,
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        workingDirectory: workingDirectory);

/// Allows you to execute a cli [commandLine].
///
/// DShell performs Glob expansion on command arguments. See [run] for details.
Progress startCommandLine(String commandLine,
    {Progress progress,
    bool runInShell = false,
    bool detached = false,
    bool terminal = false,
    String workingDirectory}) {
  return Run().fromCommandLine(commandLine,
      progress: progress,
      runInShell: runInShell,
      detached: detached,
      terminal: terminal,
      workingDirectory: workingDirectory);
}

class Run extends DShellFunction {
  RunnableProcess runnable;

  /// Runs the given [commandLine] which may contain a command and
  /// arguments to pass to the command.
  ///
  ///
  ///
  /// You may passing in a [progress] which allows you to process
  /// output as it is generated. If you pass in a [progress] the same
  /// [progress] is returned from the [run] method.
  /// If you don't passing in a [progress] then a [progress] is created
  /// and returned from the method, however as the [run] method is synchronous
  /// (like all DShell commands) you won't be able to process the output
  /// until the command completes.
  ///
  /// The returned [progress] gives you access to the exit code of the called
  /// application, if and only if you set [nothrow] to true.
  /// if [nothrow] is false (the default for most methods that use run) then
  /// a non-zero exit code will result in an exception being thrown.
  ///
  /// if [runInShell] is set to true (default is false) then command will
  /// be run in a shell (e.g. bash).
  ///
  Progress run(String commandLine,
      {Progress progress, bool runInShell = false, bool nothrow}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();
      runnable = RunnableProcess.fromCommandLine(commandLine);
      runnable.start(runInShell: runInShell);
      runnable.processUntilExit(forEach, nothrow: nothrow);
    } finally {
      forEach.close();
    }
    return forEach;
  }

  Progress fromCommandLine(String commandLine,
      {Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory,
      bool terminal}) {
    var runnable = RunnableProcess.fromCommandLine(commandLine,
        workingDirectory: workingDirectory);

    return startRunnable(runnable,
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal);
  }

  Progress fromCommandArgs(String command,
      {List<String> args,
      Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory,
      bool terminal}) {
    var runnable = RunnableProcess.fromCommandArgs(command, args,
        workingDirectory: workingDirectory);

    return startRunnable(runnable,
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal);
  }

  Progress startRunnable(RunnableProcess runnable,
      {Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory,
      bool terminal}) {
    Progress forEach;

    forEach = progress ??
        Progress((line) => print(line), stderr: (line) => printerr(line));

    try {
      runnable.start(
          runInShell: runInShell, detached: detached, terminal: terminal);
      if (detached == false) {
        if (terminal == false) {
          runnable.processUntilExit(forEach, nothrow: false);
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
