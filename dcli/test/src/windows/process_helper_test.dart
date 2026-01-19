/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/src/functions/sleep.dart';
import 'package:dcli/src/windows/process_helper.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test(
    'process helper ...',
    () async {
      final exePath = p.join(Directory.current.path, 'dcli_unit_tester', 'bin',
          'dcli_unit_tester.exe');
      final exeToRun =
          File(exePath).existsSync() ? exePath : 'dcli_unit_tester';
      final exeName = p.basename(exeToRun);
      final expectedName =
          exeName.toLowerCase().endsWith('.exe') ? exeName : '$exeName.exe';

      Process? process;
      try {
        process = await Process.start(exeToRun, ['--sleep', '5']);
        await sleepAsync(200, interval: Interval.milliseconds);

        final processes = getWindowsProcesses();
        final processNames =
            processes.map((process) => process.name.toLowerCase());

        expect(processNames, contains(expectedName.toLowerCase()));
      } finally {
        process?.kill();
      }
    },
    skip: !core.Settings().isWindows,
  );
}
