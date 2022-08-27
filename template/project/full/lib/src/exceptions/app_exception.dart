/// All exceptions thrown should 'extends' from this base class
/// as it makes it easier to catch and process exceptions
/// in a consistent fashion.
/// In large applications it can be useful to have a 'class' per
/// thrown exception as it allows for 'targeted' catch blocks.
class AppException implements Exception {
  AppException(this.message, {required this.showUsage});

  String message;
  bool showUsage;
}

/// Throw this exception or one derived from it when you want
/// the exeception cause the applicaiton to exit with the
/// given [exitCode].
/// The [exitCode] should be a positive non-zero value (zero is reserved
/// for a successful run).
class ExitException extends AppException {
  ExitException(this.exitCode, super.message, {required super.showUsage})
      : assert(exitCode != 0, '0 is reserved for a successful for run.');
  int exitCode;
}
