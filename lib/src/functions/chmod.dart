import '../../dshell.dart';
import '../util/dshell_exception.dart';
import '../util/stack_trace_impl.dart';

import 'dshell_function.dart';

/// Wrapper for the linux `chmod` command.
/// [permission] is the standard bit map used by chmod e.g. 777
/// [path] is the path to the file that we are changing the
/// permissions of.
void chmod(int permission, String path) => ChMod()._chmod(permission, path);
// String chmod({String prompt}) => ChMod().chmod(prompt: prompt);

enum permission { r, w, x }

class ChMod extends DShellFunction {
// this.user, this.group, this.other, this.path

  void _chmod(int permission, String path) {
    if (!exists(path)) {
      throw ChModException('The file at ${absolute(path)} does not exists');
    }
    'chmod ${permission} "$path"'.run;
  }

  //  String chmod({int user, int group, int other, this.path}) {}

/*  String buildPermission(int permission) {
    bool read = ((permission & 4) >> 2) == 1;
    bool write = ((permission & 2) >> 1) == 1;
    bool execute = ((permission & 1)) == 1;
  }
  */
}

class ChModException extends DShellFunctionException {
  ChModException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return ChModException(message, stackTrace);
  }
}
