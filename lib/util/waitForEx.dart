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
  DShellException exception;
  T value;
  try {
    value = cli.waitFor<T>(future);
  } on AsyncError catch (e) {
    if (e.error is DShellException) {
      exception = e.error as DShellException;
    } else {
      rethrow;
    }
  }

  if (exception != null) {
    // recreate the exception so we have a full
    // stacktrace rather than the microtask
    // stacktrace the future leaves us with.
    StackTraceImpl stackTrace = StackTraceImpl(skipFrames: 2);

    if (exception is DShellException) {
      throw exception.copyWith(stackTrace);
    } else {
      Log.w(
          "Rethrowing a non DShellException ${exception}- should we wrap this?");
      throw DShellException.from(exception, stackTrace);
    }
  }
  return value;
}
