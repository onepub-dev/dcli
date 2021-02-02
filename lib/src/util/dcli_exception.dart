import 'stack_trace_impl.dart';

/// Base class for all DCli exceptions.
class DCliException implements Exception {
  ///
  final String message;

  /// If DCliException is wrapping another exception then this is the 
  /// exeception that is wrapped.
  final Object cause;

  ///
  final StackTraceImpl stackTrace;

  ///
  DCliException(this.message, [StackTraceImpl stackTrace])
      : cause = null,
        stackTrace = stackTrace ?? StackTraceImpl(skipFrames: 2);

  ///
  DCliException copyWith(StackTraceImpl stackTrace) {
    return DCliException(message, stackTrace);
  }

  //  {
  //   return DCliException(this.message, stackTrace);
  // }

  @override
  String toString() {
    return message;
  }

  ///
  void printStackTrace() {
    print(stackTrace.formatStackTrace());
  }

  ///
  DCliException.from(this.cause, this.stackTrace)
      : message = cause.toString();
}
