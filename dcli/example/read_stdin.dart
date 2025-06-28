/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';

///
/// Demonstrates reading from stdin and writing to stdout.
//
void main() {
  readStdin().forEach(print);
}
