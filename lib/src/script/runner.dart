import 'dart:cli';
import 'dart:io';

import '../../dcli.dart';
import '../util/wait_for_ex.dart';

/// Runs a Dart dscript
class ScriptRunner {
  final DartSdk _sdk;
  final List<String> _scriptArguments;
  final Script script;

  ///
  ScriptRunner(this._sdk, this.script, this._scriptArguments);

  /// Executes the script
  int exec() {
    // Prepare VM arguments
    final vmArgs = <String>[];
    vmArgs.add('--enable-asserts');

    vmArgs.add(
        '--packages=${join(script.pathToProjectRoot, DartSdk().pathToPackageConfig)}');

    vmArgs.add(script.pathToScript);
    vmArgs.addAll(_scriptArguments);

    Settings().verbose(
        'Executing: ${DartSdk().pathToDartExe} $vmArgs, in: ${script.pathToScriptDirectory}');

    // Execute the script
    final process = waitFor<Process>(Process.start(_sdk.pathToDartExe, vmArgs,
        mode: ProcessStartMode.inheritStdio));

    final exitCode = waitForEx<int>(process.exitCode);

    return exitCode;
  }
}
