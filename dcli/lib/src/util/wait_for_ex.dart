/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

// ignore_for_file: deprecated_member_use

import 'package:dcli_core/dcli_core.dart';
import 'package:path/path.dart';
import 'package:stack_trace/stack_trace.dart';

/// merges two stack traces. Used when handling futures and you want
/// combine a futures stack exception with the original calls stack
Trace _merge(Trace caller, StackTrace wrapped) {
  final microImpl = Trace.from(wrapped);

  final merged = <Frame>[...caller.frames];

  var index = 0;
  for (final frame in microImpl.frames) {
    // best we can do is exclude any files that are in the flutter src tree.
    if (isExcludedSource(frame)) {
      continue;
    }
    merged.insert(index++, frame);
  }
  return Trace(merged);
}

String get _rootPath => rootPrefix(pwd);

List<String> _excludedSource = [
  join(_rootPath, 'flutter'),
  join(_rootPath, 'ui'),
  join(_rootPath, 'async'),
  'isolate'
];

///
bool isExcludedSource(Frame frame) {
  var excludeSource = false;

  final path = absolute(frame.library);
  for (final exclude in _excludedSource) {
    if (path.startsWith(exclude)) {
      excludeSource = true;
      break;
    }
  }
  return excludeSource;
}
