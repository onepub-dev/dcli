// ignore_for_file: deprecated_member_use

import 'dart:cli';
import 'dart:io';

import '../../dcli.dart';

/// Runs a Dart dscript
class ScriptRunner {
  ///
  ScriptRunner(this._sdk, this.script, this._scriptArguments);

  final DartSdk _sdk;
  final List<String> _scriptArguments;

  /// The script this runner exists for.
  final DartScript script;

  /// Run the script
  int run() {
    // Prepare VM arguments
    final vmArgs = <String>[
      '--enable-asserts',
      script.pathToScript,
      ..._scriptArguments
    ];

    verbose(
      () => 'Executing: ${DartSdk().pathToDartExe} $vmArgs, '
          '${script.pathToScript}',
    );

    // Execute the script
    final process = waitFor<Process>(
      Process.start(
        _sdk.pathToDartExe!,
        vmArgs,
        mode: ProcessStartMode.inheritStdio,
      ),
    );

    final exitCode = waitForEx<int>(process.exitCode);

    return exitCode;
  }
}
