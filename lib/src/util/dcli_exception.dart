import 'stack_trace_impl.dart';

/// Base class for all DCli exceptions.
class DCliException implements Exception {
  ///
  DCliException(this.message, [StackTraceImpl? stackTrace])
      : cause = null,
        stackTrace = stackTrace ?? StackTraceImpl(skipFrames: 2);

  ///
  DCliException.from(this.cause, this.stackTrace) : message = cause.toString();

  ///
  DCliException copyWith(StackTraceImpl stackTrace) => DCliException(message, stackTrace);

  ///
  final String message;

  /// If DCliException is wrapping another exception then this is the
  /// exeception that is wrapped.
  final Object? cause;

  ///
  final StackTraceImpl stackTrace;

  //  {
  //   return DCliException(this.message, stackTrace);
  // }

  @override
  String toString() => message;

  ///
  void printStackTrace() {
    print(stackTrace.formatStackTrace());
  }
}
