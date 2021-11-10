import 'dart:async';
import 'dart:cli' as cli;

import '../../dcli.dart';

import '../settings.dart';
import 'dcli_exception.dart';
import 'stack_trace_impl.dart';

/// Wraps the standard cli waitFor
/// but rethrows any exceptions with a repaired stacktrace.
///
/// The exception is wrapped in a [DCliException] with the original exception
/// in [DCliException.cause] and the repaired stacktrace in
/// [DCliException.stackTrace];
///
/// Exceptions would normally have a microtask
/// stack which is useless the repaired stack replaces the exceptions stack
/// with a full stack.
T waitForEx<T>(Future<T> future) {
  DCliException? exception;
  late StackTrace stackTrace;
  late T value;
  try {
    value = cli.waitFor<T>(future);
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    if (e.error is DCliException) {
      exception = e.error as DCliException;
      stackTrace = e.stackTrace;
    } else {
      verbose(() => 'Rethrowing a non DCliException $e');
      // ignore: only_throw_errors
      throw e.error;
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    rethrow;
  }
  // catch (e, st) {
  //   exception = e;
  //   stackTrace = st;
  // }

  if (exception != null) {
    // see issue: https://github.com/dart-lang/sdk/issues/30741
    // We currently have no way to throw the repaired stack trace.
    // The best we can do is store the repaired stack trace in the
    // DCliException.
    assert(exception is DCliException, 'Expected on DCliExceptions');
    throw exception..stackTrace = StackTraceImpl.fromStackTrace(stackTrace);
  }
  return value;
}
