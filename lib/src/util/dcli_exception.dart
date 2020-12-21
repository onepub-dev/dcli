import 'stack_trace_impl.dart';

/// Base class for all DCli exceptions.
class DCliException implements Exception {
  ///
  final String message;

  ///
  final StackTraceImpl stackTrace;

  ///
  DCliException(this.message, [StackTraceImpl stackTrace])
      : stackTrace = stackTrace ?? StackTraceImpl(skipFrames: 2);

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
  DCliException.from(Object exception, this.stackTrace)
      : message = exception.toString();
}
