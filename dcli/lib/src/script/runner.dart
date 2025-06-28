/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

// ignore_for_file: deprecated_member_use

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

    verbose(() => 'Executing: ${DartSdk().pathToDartExe} $vmArgs');

    final progress = startFromArgs(_sdk.pathToDartExe!, vmArgs,
        terminal: true, nothrow: true);
    return progress.exitCode!;
  }

  /// Run the script.
  /// If no [progress] is passed then both stdout and stderr are pritned.
  /// If no [workingDirectory] is passed then the current working directory
  /// is used.
  Progress start({
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

    // Prepare VM arguments
    final vmArgs = <String>[
      '--enable-asserts',
      script.pathToScript,
      ..._scriptArguments
    ];

    verbose(() => 'Executing: ${DartSdk().pathToDartExe} $vmArgs');

    startFromArgs(_sdk.pathToDartExe!, vmArgs,
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        privileged: privileged,
        nothrow: nothrow,
        workingDirectory: workingDirectory,
        extensionSearch: extensionSearch);

    return progress;
  }
}
