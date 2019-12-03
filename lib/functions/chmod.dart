import 'package:dshell/dshell.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/stack_trace_impl.dart';

import 'dshell_function.dart';

void chmod(int permission, String path) => ChMod().chmod(permission, path);
// String chmod({String prompt}) => ChMod().chmod(prompt: prompt);

enum permission { r, w, x }

class ChMod extends DShellFunction {
// this.user, this.group, this.other, this.path

  void chmod(int permission, String path) {
    if (!exists(path)) {
      throw ChModException("The file at ${absolute(path)} does not exists");
    }
    'chmod ${permission} $path'.run;
  }

  //  String chmod({int user, int group, int other, this.path}) {}

  String buildPermission(int permission) {
    bool read = ((permission & 4) >> 2) == 1;
    bool write = ((permission & 2) >> 1) == 1;
    bool execute = ((permission & 1)) == 1;
  }
}

class ChModException extends DShellFunctionException {
  ChModException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return ChModException(message, stackTrace);
  }
}
