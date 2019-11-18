import 'stack_trace_impl.dart';

class DShellException implements Exception {
  final String message;
  final StackTraceImpl stackTrace;

  DShellException(this.message, [StackTraceImpl stackTrace])
      : this.stackTrace = stackTrace ?? StackTraceImpl(skipFrames: 2);

  DShellException copyWith(StackTraceImpl stackTrace) {
    return DShellException(message, stackTrace);
  }

  //  {
  //   return DShellException(this.message, stackTrace);
  // }

  String toString() {
    return "An Exception was thrown: ${message}";
  }

  void printStackTrace() {
    print(stackTrace.formatStackTrace());
  }

  DShellException.from(Object exception, this.stackTrace)
      : message = exception.toString();
}
