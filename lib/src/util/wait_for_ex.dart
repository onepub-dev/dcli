import 'dart:async';
import 'dart:cli' as cli;

import '../../dcli.dart';

import 'dcli_exception.dart';
import 'stack_trace_impl.dart';

/// Wraps the standard cli waitFor
/// but rethrows any exceptions with a repaired stacktrace.
///
/// The exception is wrapped in a [DCliException] with the original exception
/// in [DCliException.cause] and the repaired stacktrace in [DCliException.stackTrace];
///
/// Exceptions would normally have a microtask
/// stack which is useless the repaired stack replaces the exceptions stack
/// with a full stack.
T waitForEx<T>(Future<T> future) {
  Exception exception;
  StackTrace asyncStackTrace;
  T value;
  try {
    value = cli.waitFor<T>(future);
  }
  // ignore: avoid_catching_errors
  catch (e) {
    if (e is AsyncError) {
      asyncStackTrace = e.stackTrace;
    }
    if (e.error is Exception) {
      exception = e.error as Exception;
    } else {
      Settings().verbose('Rethrowing a non DCliException $e');
      rethrow;
    }
  }

  if (exception != null) {
    // see issue: https://github.com/dart-lang/sdk/issues/30741
    // We currently have now way to throw the repaired stack trace.
    // The best we can do is store the repaired stack trace in the DCliException.
    if (exception is DCliException) {
      throw exception.copyWith(StackTraceImpl.fromStackTrace(asyncStackTrace));
    } else {
      /// Ideally we would rather throw the original exception but currently there is no way to do this.
      throw DCliException.from(
          exception, StackTraceImpl.fromStackTrace(asyncStackTrace));
    }
  }
  return value;
}
