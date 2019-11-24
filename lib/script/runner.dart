import 'dart:async';
import 'dart:cli';
import "dart:io";

import 'package:dshell/util/waitForEx.dart';

import 'dart_sdk.dart';
import 'project.dart';

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
    vmArgs.add("--enable-asserts");
    vmArgs.addAll(["--packages=${project.path}/.packages"]);
    vmArgs.add(project.script.scriptname);
    vmArgs.addAll(scriptArguments);

    // Execute the script
    final Process process = waitFor<Process>(Process.start(
        Platform.executable, vmArgs,
        workingDirectory: project.path));

    // Pipe std out and in
    final StreamSubscription stderrSub =
        process.stderr.listen((List<int> d) => stderr.add(d));
    final StreamSubscription stdoutSub =
        process.stdout.listen((List<int> d) => stdout.add(d));
    final StreamSubscription stdinSub =
        stdin.listen((List<int> d) => process.stdin.add(d));

    final int exitCode = waitForEx<int>(process.exitCode);

    final List<Future<void>> futures = List();

    futures.add(stderrSub.cancel());
    futures.add(stdoutSub.cancel());
    futures.add(stdinSub.cancel());

    waitFor<void>(Future.wait(futures));

    return exitCode;
  }
}
