import 'dart:io' as io;

import 'package:dcli_core/dcli_core.dart';
import 'package:scope/scope.dart';

import 'unit_test.dart';

/// Use this method rather than dart:io.exit()
/// as it is unit test friendly in that it
/// will throw an [ExitException] to avoid
/// shutting the entire unit test framework down.
void dcliExit(int exitCode) {
  if (Scope.use(unitTestingKey)) {
    // If we allow the call to io.exit to proceed
    // then the unit test framework would shutdown.
    // so instead we throw an exception.
    throw ExitException(exitCode);
  }

  // so we are not in a unit test, so we can just shutdown
  io.exit(exitCode);
}

/// Thrown when exit() called and we are in a unit
/// test. We don't derive from [DCliException] as this
/// exists outside the normal set of exceptions so
/// we don't want it being caught like a [DCliException].
class ExitException implements Exception {
  ExitException(this.exitCode);
  int exitCode;
}
