import 'dart:cli' as cli;
import 'dart:async';
import 'dshell_exception.dart';
import 'log.dart';
import 'stack_trace_impl.dart';

/// Wraps the standard cli waitFor
/// but rethrows any exceptions with
/// a stack that is cohernt.
/// Exceptions would normally have a microtask
/// stack which is useless.
/// This version replaces the exceptions stack
/// with a full stack.
T waitForEx<T>(Future<T> future) {
  Exception exception;
  T value;
  try {
    value = cli.waitFor<T>(future);
  } on AsyncError catch (e) {
    if (e.error is Exception) {
      exception = e.error as Exception;
    } else {
      Log.e('Rethrowing a non DShellException ${e}', stackTrace: e.stackTrace);
      rethrow;
    }
  }

  if (exception != null) {
    // recreate the exception so we have a full
    // stacktrace rather than the microtask
    // stacktrace the future leaves us with.
    var stackTrace = StackTraceImpl(skipFrames: 2);

    if (exception is DShellException) {
      throw exception.copyWith(stackTrace);
    } else {
      throw DShellException.from(exception, stackTrace);
    }
  }
  return value;
}
