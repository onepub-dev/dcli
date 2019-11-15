import 'package:dshell/util/stack_trace_impl.dart';
import 'package:path/path.dart' as p;

class Command {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

class CommandException implements Exception {
  String message;
  StackTraceImpl stackTrace;

  CommandException(this.message) {
    stackTrace = StackTraceImpl(skipFrames: 2);
  }

  CommandException.rebuild(CommandException e, StackTraceImpl stackTrace) {
    message = e.message;
    this.stackTrace = stackTrace;
  }

  String toString() {
    return "An Exception was thrown: ${message}";
  }

  void printStackTrace() {
    print(stackTrace.formatStackTrace());
  }
}
