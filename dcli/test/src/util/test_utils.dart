/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

// Creates text file with the given no. of lines.
void createLineFile(String testFile, int lines) {
  if (exists(testFile)) {
    delete(testFile);
  }

  if (!exists(dirname(testFile))) {
    createDir(dirname(testFile));
  }

  withOpenFile(testFile, (file) {
    for (var i = 0; i < 10; i++) {
      file.append('Line $i is here');
    }
  });
}
