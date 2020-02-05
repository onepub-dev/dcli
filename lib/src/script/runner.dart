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
    vmArgs.add('--package-root=${project.path}'); // /.packages');
    vmArgs.add(join(project.path, project.script.scriptname));
    vmArgs.addAll(scriptArguments);

    Settings().verbose(
        'Executing: ${DartSdk().dartPath} $vmArgs, in: ${project.script.scriptDirectory}');

    // Execute the script
    final process = waitFor<Process>(Process.start(Platform.executable, vmArgs,
        mode: ProcessStartMode.inheritStdio));

    final exitCode = waitForEx<int>(process.exitCode);

    return exitCode;
  }
}
