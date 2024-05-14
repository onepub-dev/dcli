/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import '../util/runnable_process.dart';

///
/// Runs the given cli [commandLine] writing any output
/// from both stdout and stderr to the console.
///
/// if the [nothrow] argument is false (the default) then
/// a non-zero exit code will result in [RunException] been thrown.
/// The [RunException] will contain the non-zero exit code.
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
/// The [privileged] argument attempts to escalate the priviledge that
///  the command is run
/// at.
/// If the script is already running in a priviledge environment this s
/// witch will have no
/// affect.
/// Running a command with the [privileged] switch may cause the OS to
/// prompt the user
/// for a password.
///
/// For Linux passing the [privileged] argument will cause the command
///  to be prefix
/// vai the `sudo` command.
///
/// Current [privileged] is only supported under Linux.
///
/// DCli performs glob (wildcard) expansion on command arguments if it
/// contains any one
/// of *, [ or ?  unless the argument is quoted.
/// DCli uses the dart package Glob (https://pub.dev/packages/glob) to do the glob expansion.
///
/// The following command will have the argument containing the
/// wild card *.dart expanded to
/// the list of files, in the current directory, that match the
/// pattern *.dart. If no files match the pattern then the pattern
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
///  * [start]
///  * [startFromArgs]
///  for methods that allow you to process data rather
/// than just outputing it to the cli.
///
int? run(
  String commandLine, {
  bool runInShell = false,
  bool nothrow = false,
  bool privileged = false,
  String? workingDirectory,
  bool extensionSearch = true,
}) {
  workingDirectory ??= pwd;

  final runnable = RunnableProcess.fromCommandLine(
    commandLine,
    workingDirectory: workingDirectory,
  );

  return runnable
      .run(
        progress: Progress.print(),
        runInShell: runInShell,
        terminal: false,
        privileged: privileged,
        nothrow: nothrow,
        extensionSearch: extensionSearch,
      )
      .exitCode;
}

/// Allows you to execute a command by passing a [command]
/// and a list of args in [args].
///
/// The [startFromArgs] method provides additional controls
/// (compared to the run method) over how the commmand is executed.
///
/// DCli will do glob expansion (e.g. expand *.txt to a list of txt files)
/// on each passed argument (for Linux and MacOS).
/// You can stop glob expansion by adding a set of single or double quotes
///  around each argument.
///
/// DCli will remove the extra quotes and NOT perform glob expansion.
///
/// e.g.
/// '''"dontexpand.*"'''
///
/// results in
/// dontexpand.*
///
/// By default [startFromArgs] will output both stdout and stderr to
/// the console.
///
/// Pass in a [progress] to capture or suppress stdout and stderr.
///
///
/// The [privileged] argument attempts to escalate the priviledge that
///  the command is run with.
///
/// If the script is already running in a priviledge environment this
/// switch will have no affect.
///
/// Running a command with the [privileged] switch may cause the OS to
/// prompt the user for a password.
///
/// For Linux/MacOS passing the [privileged] argument will cause the command
/// to be prefix vai the `sudo` command unless the script is already
/// running as a privileged process.
///
/// Currently [privileged] is not supported under Windows see withPrivileged as
/// an alternative.
///
/// If you pass [detached] = true then the process is spawned but we don't wait
/// for it to complete nor is any io available.
///
Progress startFromArgs(
  String command,
  List<String> args, {
  Progress? progress,
  bool runInShell = false,
  bool detached = false,
  bool terminal = false,
  bool privileged = false,
  bool nothrow = false,
  String? workingDirectory,
  bool extensionSearch = true,
}) {
  progress ??= Progress.print();
  workingDirectory ??= pwd;
  final runnable = RunnableProcess.fromCommandArgs(
    command,
    args,
    workingDirectory: workingDirectory,
  );

  return runnable.run(
    progress: progress,
    runInShell: runInShell,
    detached: detached,
    terminal: terminal,
    privileged: privileged,
    nothrow: nothrow,
    extensionSearch: extensionSearch,
  );
}

/// Allows you to execute a cli [commandLine].
///
/// DCli performs Glob expansion on command arguments. See [run] for details.
///
/// Runs the given [commandLine] which may contain a command and
/// arguments to pass to the command.
///
///
///
/// You may pass in a [progress] which allows you to process
/// output as it is generated. If you pass in a [progress] the same
/// [progress] is returned from the [start] method.
///
/// If you don't passing in a [progress] then a default [progress] is created
/// which suppresses output from both stdout and stderr.
///
/// and returned from the method, however as the [run] method is synchronous
/// (like all DCli commands) you won't be able to process the output
/// until the command completes.
///
/// The returned [progress] gives you access to the exit code of the called
/// application, if and only if you set [nothrow] to true.
/// if [nothrow] is false (the default for most methods that use run) then
/// a non-zero exit code will result in an exception being thrown.
///
/// The [privileged] argument attempts to escalate the priviledge that
/// the command is run
/// at.
/// If the script is already running in a priviledge environment this
///  switch will have no
/// affect.
/// Running a command with the [privileged] switch may cause the OS to
///  prompt the user
/// for a password.
///
/// For Linux passing the [privileged] argument will cause the command
///  to be prefix
/// vai the `sudo` command.
///
/// Current [privileged] is only supported under Linux.
///
/// if [runInShell] is set to true (default is false) then command will
/// be run in a shell (e.g. bash).
///
/// If you pass [detached] = true then the process is spawned but we don't wait
/// for it to complete nor is any io available.
///
Progress start(
  String commandLine, {
  Progress? progress,
  bool runInShell = false,
  bool detached = false,
  bool terminal = false,
  bool nothrow = false,
  bool privileged = false,
  String? workingDirectory,
  bool extensionSearch = true,
}) {
  workingDirectory ??= pwd;
  final runnable = RunnableProcess.fromCommandLine(
    commandLine,
    workingDirectory: workingDirectory,
  );

  return runnable.run(
    progress: progress,
    runInShell: runInShell,
    detached: detached,
    terminal: terminal,
    privileged: privileged,
    nothrow: nothrow,
    extensionSearch: extensionSearch,
  );
}

///
/// The [privileged] argument attempts to escalate the priviledge that
///  the command is run
/// at.
/// If the script is already running in a priviledge environment this
///  switch will have no
/// affect.
/// Running a command with the [privileged] switch may cause the OS to
///  prompt the user
/// for a password.
///
/// For Linux passing the [privileged] argument will cause the command
///  to be prefix
/// vai the `sudo` command.
///
/// Current [privileged] is only supported under Linux.
///
// Future<Progress> startStreaming(
//   String commandLine, {
//   Progress? progress,
//   bool runInShell = false,
//   bool nothrow = false,
//   bool privileged = false,
//   String? workingDirectory,
//   bool extensionSearch = true,
// }) async {
//   workingDirectory ??= pwd;
//   final runnable = RunnableProcess.fromCommandLine(
//     commandLine,
//     workingDirectory: workingDirectory,
//   );

//   return runnable.runStreaming(
//     progress: progress,
//     runInShell: runInShell,
//     privileged: privileged,
//     nothrow: nothrow,
//     extensionSearch: extensionSearch,
//   );
// }
