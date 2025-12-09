/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// The base implementation for all Progress implementations.
abstract class ProgressImpl {
  int? exitCode;

  /// adds the [data] to the stdout controller
  void addToStdout(List<int> data);

  /// adds the [data] to the stderr controller
  void addToStderr(List<int> data);

  // for progresses that need to be cleaned up such
  // as streams - I think.
  void close();
}
