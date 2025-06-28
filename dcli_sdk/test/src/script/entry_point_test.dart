/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_sdk/src/script/entry_point.dart';
import 'package:test/test.dart';

void main() {
  test('entry point ...', () async {
    await EntryPoint().process(['--verbose', 'create']);
  });
}
