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
int availableSpace(String path) {
  if (!exists(path)) {
    throw FileSystemException(
      "The given path ${truepath(path)} doesn't exists",
    );
  }

  final lines = 'df -h "$path"'.toList();
  if (lines.length != 2) {
    throw FileSystemException(
      "An error occured retrieving the device path: ${lines.join('\n')}",
    );
  }

  final line = lines[1];
  final parts = line.split(RegExp(r'\s+'));

  if (parts.length != 6) {
    throw FileSystemException('An error parsing line: $line');
  }

  final factors = {'G': 1000000000, 'M': 1000000, 'K': 1000, 'B': 1};

  final havailable = parts[3];

  if (havailable == '0') {
    return 0;
  }

  final factoryLetter = havailable.substring(havailable.length - 1);
  final hsize = havailable.substring(0, havailable.length - 1);

  final factor = factors[factoryLetter];
  if (factor == null) {
    throw FileSystemException(
      "Unrecognized size factor '$factoryLetter' in $havailable",
    );
  }

  return int.tryParse(hsize)! * factor;
}
