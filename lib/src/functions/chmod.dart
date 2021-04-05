import '../../dcli.dart';
import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

import 'dcli_function.dart';

/// Wrapper for the linux `chmod` command.
///
/// [permission] is the standard bit map used by chmod e.g. 777
/// [path] is the path to the file that we are changing the
/// permissions of.
void chmod(int permission, String path) => _ChMod()._chmod(permission, path);

/// Implementatio for [chmod] function.
class _ChMod extends DCliFunction {
// this.user, this.group, this.other, this.path

  void _chmod(int permission, String path) {
    if (!exists(path)) {
      throw ChModException('The file at ${truepath(path)} does not exists');
    }
    'chmod $permission "$path"'.run;
  }

  //  String chmod({int user, int group, int other, this.path}) {}

/*  String buildPermission(int permission) {
    bool read = ((permission & 4) >> 2) == 1;
    bool write = ((permission & 2) >> 1) == 1;
    bool execute = ((permission & 1)) == 1;
  }
  */
}

/// Thrown if the [chmod] function encounters an error.
class ChModException extends DCliFunctionException {
  /// Thrown if the [chmod] function encounters an error.
  ChModException(String reason, [StackTraceImpl? stacktrace])
      : super(reason, stacktrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) =>
      ChModException(message, stackTrace);
}
