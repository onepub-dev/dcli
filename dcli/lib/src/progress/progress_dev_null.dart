/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'progress.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

class ProgressDevNullImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressDevNull {
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
