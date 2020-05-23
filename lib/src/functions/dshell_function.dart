import 'package:path/path.dart' as p;
import '../util/dshell_exception.dart';
import '../util/stack_trace_impl.dart';

/// Base class for the classes that implement
/// the public DShell functions.
class DShellFunction {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

/// Base class for all dshell function exceptions.
class DShellFunctionException extends DShellException {
  /// Base class for all dshell function exceptions.
  DShellFunctionException(String message, [StackTraceImpl stackTrace])
      : super(message, stackTrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return DShellFunctionException(message, stackTrace);
  }
}
