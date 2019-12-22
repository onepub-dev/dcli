import 'stack_trace_impl.dart';

class DShellException implements Exception {
  final String message;
  final StackTraceImpl stackTrace;

  DShellException(this.message, [StackTraceImpl stackTrace])
      : stackTrace = stackTrace ?? StackTraceImpl(skipFrames: 2);

  DShellException copyWith(StackTraceImpl stackTrace) {
    return DShellException(message, stackTrace);
  }

  //  {
  //   return DShellException(this.message, stackTrace);
  // }

  @override
  String toString() {
    return '${message}';
  }

  void printStackTrace() {
    print(stackTrace.formatStackTrace());
  }

  DShellException.from(Object exception, this.stackTrace)
      : message = exception.toString();
}
