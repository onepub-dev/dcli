import 'package:stacktrace_impl/stacktrace_impl.dart';

import 'dcli_exception.dart';

/// Thrown when any of the process related method
/// such as .run and .start fail.
class RunException extends DCliException {
  ///
  RunException(
    this.cmdLine,
    this.exitCode,
    this.reason, {
    StackTraceImpl? stackTrace,
  }) : super(reason, stackTrace);

  ///
  RunException.withArgs(
    String? cmd,
    List<String?> args,
    this.exitCode,
    this.reason, {
    StackTraceImpl? stackTrace,
  })  : cmdLine = '$cmd ${args.join(' ')}',
        super(reason, stackTrace);

  // @override
  // RunException copyWith(StackTraceImpl stackTrace) =>
  //     RunException(cmdLine, exitCode, reason, stackTrace: stackTrace);

  /// The command line that was being run.
  String cmdLine;

  /// the exit code of the command.
  int? exitCode;

  /// the error.
  String reason;

  @override
  String get message => '''
$cmdLine 
exit: $exitCode
reason: $reason''';
}
