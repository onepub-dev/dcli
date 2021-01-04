import 'package:path/path.dart' as p;
import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

/// Base class for the classes that implement
/// the public DCli functions.
class DCliFunction {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

/// Base class for all dcli function exceptions.
class DCliFunctionException extends DCliException {
  /// Base class for all dcli function exceptions.
  DCliFunctionException(String message, [StackTraceImpl? stackTrace])
      : super(message, stackTrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) {
    return DCliFunctionException(message, stackTrace);
  }
}
