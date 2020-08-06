import 'dart:cli';
import 'dart:io';

import '../../dshell.dart';
import '../util/wait_for_ex.dart';
import 'virtual_project.dart';

/// Runs a Dart dscript
class ScriptRunner {
  final VirtualProject _project;
  final DartSdk _sdk;
  final List<String> _scriptArguments;
  final Script script;

  ///
  ScriptRunner(this._sdk, this._project, this.script, this._scriptArguments);

  /// Executes the script
  int exec() {
    // Prepare VM arguments
    final vmArgs = <String>[];
    vmArgs.add('--enable-asserts');

    var projectRoot = script.projectRoot;

    if (!script.hasLocalPubSpecYaml()) {
      projectRoot = _project.runtimeProjectPath;
    }

    vmArgs.add(
        '--packages=${join(projectRoot, '.dart_tool/package_config.json')}');

    vmArgs.add(join(_project.runtimeProjectPath, _project.script.scriptname));
    vmArgs.addAll(_scriptArguments);

    Settings().verbose(
        'Executing: ${DartSdk().dartExePath} $vmArgs, in: ${_project.script.scriptDirectory}');

    // Execute the script
    final process = waitFor<Process>(Process.start(_sdk.dartExePath, vmArgs,
        mode: ProcessStartMode.inheritStdio));

    final exitCode = waitForEx<int>(process.exitCode);

    return exitCode;
  }
}
