import 'package:path/path.dart' as p;
import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

/// Based class for all function
class DCliFunction {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

/// Based class for all function exceptions.
class FunctionException extends DCliException {
  /// Based class for all function exceptions.
  FunctionException(String message, [StackTraceImpl stackTrace])
      : super(message, stackTrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) {
    return FunctionException(message, stackTrace);
  }
}
