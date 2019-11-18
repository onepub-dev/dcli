import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/stack_trace_impl.dart';
import 'package:path/path.dart' as p;

class Command {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

class CommandException extends DShellException {
  CommandException(String message, [StackTraceImpl stackTrace])
      : super(message, stackTrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return CommandException(message, stackTrace);
  }
}
