/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

///
/// devNull is a convenience function which you can use
/// if you want to ignore the output of a LineAction.
/// Its typical useage is a forEach where you don't want
/// to see any stdout but you still want to see errors
/// printed to stderr.
///
/// ```dart
/// 'git pull'.forEach(devNull, stderr: (line) => printerr(line));
/// ```
///
/// use this to consume the output.
void devNull(String? line) {}
