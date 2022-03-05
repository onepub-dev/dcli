// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:cli' as cli;

import 'package:logging/logging.dart';

import '../../dcli.dart';

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
  final stackTrace = StackTraceImpl();
  DCliException? exception;
  late StackTrace microTaskStackTrace;
  late T value;
  try {
    value = cli.waitFor<T>(future);
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    microTaskStackTrace = e.stackTrace;

    if (e.error is DCliException) {
      exception = e.error as DCliException;
    } else {
      final merged = stackTrace.merge(microTaskStackTrace);
      Logger('dcli').severe(() => '''
Rethrowing a non DCliException $e 
$merged''');

      // When dart 2.16 is released we can use this which fixes the stack
      // properly
      Error.throwWithStackTrace(e.error, merged);
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    rethrow;
  }

  if (exception != null) {
    // see issue: https://github.com/dart-lang/sdk/issues/30741
    // adn https://github.com/dart-lang/sdk/issues/10297
    // We currently have no way to throw the repaired stack trace.
    // The best we can do is store the repaired stack trace in the
    // DCliException.

    final merged = stackTrace.merge(microTaskStackTrace);

    Error.throwWithStackTrace(exception, merged);
  }
  return value;
}
