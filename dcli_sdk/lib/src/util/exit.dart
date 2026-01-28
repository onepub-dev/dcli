import 'dart:io' as io;

import 'package:dcli/dcli.dart';
import 'package:dcli_common/dcli_common.dart';
import 'package:scope/scope.dart';

/// Use this method rather than dart:io.exit()
/// as it is unit test friendly in that it
/// will throw an [ExitException] to avoid
/// shutting the entire unit test framework down.
/// @Throwing(ExitException)
/// @Throwing(MissingDependencyException)
/// @Throwing(UnsupportedError)
void dcliExit(int exitCode) {
  // The unitTestKey is intentionally breach as it is used
  // to avoid unit test being shutdown be a call to io.exit.
  if (Scope.use(UnitTestController.unitTestingKey)) {
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
  int exitCode;

  ExitException(this.exitCode);
}
