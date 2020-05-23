import '../util/progress.dart';
import '../util/runnable_process.dart';

import 'pwd.dart';

///
/// Runs the given cli [commandline] writing any output
/// from both stdout and stderr to the console.
///
/// if the [nothrow] argument is false (the default) then
/// a non-zero exit code will result in RunException been thrown.
/// The RunException will contain the non-zero exit code.
///
/// As stderr is written to the console the associated error message
/// will have been written to the console before the command exists.
///
/// if the [nothrow] argument is true then a non-zero exit code will
/// NOT result in an exception. Instead the [run] method will return the
/// exit code. Again any error message will have been written to the console
/// before the command exists.
///
/// If you pass a [workingDirectory] the command will run in the
/// given [workingDirectory]. If the [workingDirectory] is not specified
/// then the command will be run in the current working directory.
///
/// Use the [runInShell] argument if you need your command to be spawned
/// within a shell (e.g. bash). This may be necessary if you need to access
/// a command builtin to the shell.
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
/// run('ls *.dart');
/// ```
///
/// If you add quotes around the wild card then it will not be expanded:
///
/// ```dart
/// run('find . -name "*.dart"', workingDirectory: HOME);
/// ```
///
/// Run the command and do not throw an exception if a non-zero
/// exist code is returned.
///
/// ```dart
/// int exitCode = run('ls *.dart', nothrow=true);
/// ```
///
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// The [nothrow] argument is EXPERIMENTAL
///
/// See:
///     [start] or [startCommandLine] for methods that allow you to
///      process data rather than just outputing it to the cli.
///
int run(String commandLine,
    {bool runInShell = false, bool nothrow = false, String workingDirectory}) {
  workingDirectory ??= pwd;

  var runnable = RunnableProcess.fromCommandLine(commandLine,
      workingDirectory: workingDirectory);

  return runnable
      .run(
          progress: Progress(print, stderr: printerr),
          runInShell: runInShell,
          detached: false,
          terminal: false,
          nothrow: nothrow)
      .exitCode;
}

/// Allows you to execute a command by passing a [command]
/// and a list of args in [args].
///
/// The
///
/// The start method provides additional controls (compared to the run method)
/// over how the commmand is executed.
///
///
/// DShell performs Glob expansion on command arguments. See [run] for details.
///
Progress startFromArgs(
  String command,
  List<String> args, {
  Progress progress,
  bool runInShell = false,
  bool detached = false,
  bool terminal = false,
  bool nothrow = false,
  String workingDirectory,
}) {
  workingDirectory ??= pwd;
  var runnable = RunnableProcess.fromCommandArgs(command, args,
      workingDirectory: workingDirectory);

  return runnable.run(
      progress: progress,
      runInShell: runInShell,
      detached: detached,
      terminal: terminal,
      nothrow: false);
}

/// Allows you to execute a cli [commandLine].
///
/// DShell performs Glob expansion on command arguments. See [run] for details.
///
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
Progress start(String commandLine,
    {Progress progress,
    bool runInShell = false,
    bool detached = false,
    bool terminal = false,
    bool nothrow = false,
    String workingDirectory}) {
  workingDirectory ??= pwd;
  var runnable = RunnableProcess.fromCommandLine(commandLine,
      workingDirectory: workingDirectory);

  return runnable.run(
      progress: progress,
      runInShell: runInShell,
      detached: detached,
      terminal: terminal,
      nothrow: nothrow);
}
