/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'progress.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Creates a Progress that discards all output.
class ProgressDevNullImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressDevNull {
  ProgressDevNullImpl({super.encoding});

  @override
  void addToStderr(List<int> data) {
    /// just dump the data the ground as this is dev null
  }

  @override
  void addToStdout(List<int> data) {
    /// just dump the data the ground as this is dev null
  }

  @override
  void close() {
    // NOOP
  }

  /// Always returns null as we dsicard all lines.
  @override
  String? get firstLine => null;

  @override

  /// As this is devNull it will always return an empty string.
  List<String> get lines => [];
}

abstract class ProgressDevNull implements Progress {}
