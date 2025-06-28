/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

/// Writes [content] to the file at [path].
/// The file is trunctated and then written to.
///
void writeToFile(String path, String content) {
  File file;

  file = File(path);

  file.openSync(mode: FileMode.write)
    ..writeStringSync(content)
    ..closeSync();
}
