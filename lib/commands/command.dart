import 'package:dshell/util/dshell_exception.dart';
import 'package:path/path.dart' as p;

class Command {
  /// Returns the absolute path of [path]
  /// If [path] does not start with a /
  /// then it is treated as a relative path
  /// to the current working directory.
  String absolute(String path) => p.absolute(path);
}

class CommandException extends DShellException {
  CommandException(String message) : super(message);
}
