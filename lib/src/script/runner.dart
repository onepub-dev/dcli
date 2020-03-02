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
    vmArgs.add('--package-root=${project.runtimeProjectPath}'); // /.packages');
    vmArgs.add(join(project.runtimeProjectPath, project.script.scriptname));
    vmArgs.addAll(scriptArguments);

    Settings().verbose(
        'Executing: ${DartSdk().dartExePath} $vmArgs, in: ${project.script.scriptDirectory}');

    // Execute the script
    final process = waitFor<Process>(Process.start(sdk.dartExePath, vmArgs,
        mode: ProcessStartMode.inheritStdio));

    final exitCode = waitForEx<int>(process.exitCode);

    return exitCode;
  }
}
