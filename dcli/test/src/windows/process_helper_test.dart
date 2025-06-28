/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/src/windows/process_helper.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:test/test.dart';

void main() {
  test(
    'process helper ...',
    () async {
      final processes = getWindowsProcesses();

      expect(processes.map((process) => process.name), contains('dart.exe'));
    },
    skip: !core.Settings().isWindows,
  );
}
