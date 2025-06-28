/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';

/// Wipes the entire HOME/.dcli directory tree.
void wipe() {
  final dcliPath = Settings().pathToDCli;
  if (exists(dcliPath)) {
    deleteDir(dcliPath);
  }
}
