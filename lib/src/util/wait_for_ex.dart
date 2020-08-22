import 'dart:async';
import 'dart:cli' as cli;

import '../../dcli.dart';

import 'dcli_exception.dart';
import 'stack_trace_impl.dart';

/// Wraps the standard cli waitFor
/// but rethrows any exceptions with
/// a stack that is coherent.
/// Exceptions would normally have a microtask
/// stack which is useless.
/// This version replaces the exceptions stack
/// with a full stack.
T waitForEx<T>(Future<T> future) {
  Exception exception;
  T value;
  try {
    value = cli.waitFor<T>(future);
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    if (e.error is Exception) {
      exception = e.error as Exception;
    } else {
      Settings().verbose('Rethrowing a non DCliException $e');
      rethrow;
    }
  }

  if (exception != null) {
    // recreate the exception so we have a full
    // stacktrace rather than the microtask
    // stacktrace the future leaves us with.
    var stackTrace = StackTraceImpl(skipFrames: 2);

    if (exception is DCliException) {
      throw exception.copyWith(stackTrace);
    } else {
      throw DCliException.from(exception, stackTrace);
    }
  }
  return value;
}
