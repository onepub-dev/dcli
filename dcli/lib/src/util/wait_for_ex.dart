/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:cli' as cli;

import '../../dcli.dart';

/// Changes a async call into a synchronous call.
///
/// ```dart
/// waitForEx(someAsyncFunction());
/// ```
///
/// Wraps the standard cli waitFor
/// but rethrows any exceptions with a repaired stacktrace.
///
/// Exceptions would normally have a microtask
/// stack which is useless. The repaired stack replaces the exceptions stack
/// with a full stack.
T waitForEx<T>(Future<T> future) {
  final stackTrace = StackTraceImpl();
  late T value;
  try {
    value = cli.waitFor<T>(future);
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    Error.throwWithStackTrace(e.error, stackTrace.merge(e.stackTrace));
    // ignore: avoid_catches_without_on_clauses
  } catch (e, st) {
    Error.throwWithStackTrace(e, stackTrace.merge(st));
  }

  return value;
}
