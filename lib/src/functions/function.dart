import '../util/dshell_exception.dart';
import '../util/stack_trace_impl.dart';
import 'package:path/path.dart' as p;

class DShellFunction {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

class FunctionException extends DShellException {
  FunctionException(String message, [StackTraceImpl stackTrace])
      : super(message, stackTrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return FunctionException(message, stackTrace);
  }
}
