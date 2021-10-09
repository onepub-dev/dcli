import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

/// Based class for all function
class DCliFunction {}

/// Based class for all function exceptions.
class FunctionException extends DCliException {
  /// Based class for all function exceptions.
  FunctionException(String message, [StackTraceImpl? stackTrace])
      : super(message, stackTrace);
}
