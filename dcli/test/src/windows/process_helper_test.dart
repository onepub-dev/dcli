/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/src/windows/process_helper.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('process helper ...', () async {
    final temporary = Directory.systemTemp.createTempSync('dcli-process-');
    final script = File(p.join(temporary.path, 'wait.dart'))
      ..writeAsStringSync("""
import 'dart:async';
void main() {
  print('ready');
  Timer(const Duration(minutes: 1), () {});
}
""");
    final expectedName = p.basename(Platform.resolvedExecutable);

    Process? process;
    try {
      process = await Process.start(Platform.resolvedExecutable, [script.path]);
      await process.stdout.first;

      final processes = getWindowsProcesses();
      final processNames = processes.map(
        (process) => process.name.toLowerCase(),
      );

      expect(processNames, contains(expectedName.toLowerCase()));
    } finally {
      process?.kill();
      if (process != null) await process.exitCode;
      temporary.deleteSync(recursive: true);
    }
  }, skip: !core.Settings().isWindows);
}
