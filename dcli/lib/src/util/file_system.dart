/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import '../../dcli.dart';

/// Returns the amount of space (in bytes) available on the disk
/// that [path] exists on.
/// Throws [FileSystemException].
/// @Throwing(ArgumentError)
/// @Throwing(FileSystemException)
int availableSpace(String path) {
  if (!exists(path)) {
    throw FileSystemException(
      "The given path ${truepath(path)} doesn't exists",
    );
  }

  // POSIX output fixes the block size and layout on both GNU and BSD df.
  final lines = 'df -Pk "$path"'.toList();
  if (lines.length != 2) {
    throw FileSystemException(
      "An error occurred retrieving the device path: ${lines.join('\n')}",
    );
  }

  final line = lines[1];
  final parts = line.trim().split(RegExp(r'\s+'));
  final blocks = parts.length >= 6 ? int.tryParse(parts[3]) : null;
  if (blocks == null) {
    throw FileSystemException('An error parsing line: $line');
  }

  return blocks * 1024;
}
