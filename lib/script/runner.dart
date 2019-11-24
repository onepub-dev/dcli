import "dart:async";
import "dart:io";

import 'dart_sdk.dart';
import 'project.dart';

/// Runs a Dart dscript
class ScriptRunner {
  Project project;
  DartSdk sdk;
  List<String> scriptArguments;

  ScriptRunner(this.sdk, this.project, this.scriptArguments);

  /// Executes the script
  Future<int> exec() async {
    // Prepare VM arguments
    final vmArgs = <String>[];
    vmArgs.add("--enable-asserts");
    vmArgs.addAll(["--packages=${project.projectCacheDir}/.packages"]);
    vmArgs.add(project.script.scriptname);
    vmArgs.addAll(scriptArguments);

    // Execute the script
    final Process process = await Process.start(Platform.executable, vmArgs,
        workingDirectory: project.projectCacheDir);

    // Pipe std out and in
    final StreamSubscription stderrSub =
        process.stderr.listen((List<int> d) => stderr.add(d));
    final StreamSubscription stdoutSub =
        process.stdout.listen((List<int> d) => stdout.add(d));
    final StreamSubscription stdinSub =
        stdin.listen((List<int> d) => process.stdin.add(d));

    final int exitCode = await process.exitCode;

    final List<Future<void>> futures = List();

    futures.add(stderrSub.cancel());
    futures.add(stdoutSub.cancel());
    futures.add(stdinSub.cancel());

    await Future.wait(futures);

    return exitCode;
  }
}
