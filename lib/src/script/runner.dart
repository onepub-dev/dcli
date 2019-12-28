import 'dart:async';
import 'dart:cli';
import 'dart:io';

import 'package:dshell/dshell.dart';

import 'virtual_project.dart';
import '../util/waitForEx.dart';

import 'dart_sdk.dart';

/// Runs a Dart dscript
class ScriptRunner {
  VirtualProject project;
  DartSdk sdk;
  List<String> scriptArguments;

  ScriptRunner(this.sdk, this.project, this.scriptArguments);

  /// Executes the script
  int exec() {
    // Prepare VM arguments
    final vmArgs = <String>[];
    vmArgs.add('--enable-asserts');
    vmArgs.addAll(['--package-root=${project.path}/.packages']);
    vmArgs.add(project.script.scriptname);
    vmArgs.addAll(scriptArguments);

    Settings().verbose(
        'Executing: ${Platform.executable} $vmArgs, in: ${project.script.scriptDirectory}');

    // Execute the script
    final process = waitFor<Process>(Process.start(Platform.executable, vmArgs,
        workingDirectory: project.script.scriptDirectory));

    // Pipe std out and in
    final StreamSubscription stderrSub =
        process.stderr.listen((List<int> d) => stderr.add(d));
    final StreamSubscription stdoutSub =
        process.stdout.listen((List<int> d) => stdout.add(d));
    final StreamSubscription stdinSub =
        stdin.listen((List<int> d) => process.stdin.add(d));

    final exitCode = waitForEx<int>(process.exitCode);

    final futures = <Future<void>>[];

    futures.add(stderrSub.cancel());
    futures.add(stdoutSub.cancel());
    futures.add(stdinSub.cancel());

    waitFor<void>(Future.wait(futures));

    return exitCode;
  }
}
