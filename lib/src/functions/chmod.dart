import 'dart:io';

import '../../dcli.dart';
import '../util/stack_trace_impl.dart';

import 'dcli_function.dart';

/// Wrapper for the linux `chmod` command.
///
/// [permission] is the standard bit map used by chmod e.g. 777
/// [path] is the path to the file that we are changing the
/// permissions of.
///
/// The the [permission] digits are intrepeted as owner, group, other.
/// So:
/// 641
/// owner - 6
/// group - 4
/// other - 1
///
/// Each digit is the sum of the permissions:
/// 4 - allow read
/// 2 - allow write
/// 1 - all execute
///
/// So 6 is 4 + 2 is read and write.
///
/// To set give the owner execution privileges use:
/// ```dart
/// chmod(100, '/path/to/exe');
/// ```
/// If [path] doesn't exist a ChModException] is thrown.
///
/// On Windows a call to this method is a noop.
///
void chmod(int permission, String path) => _ChMod()._chmod(permission, path);

/// Implementatio for [chmod] function.
class _ChMod extends DCliFunction {
// this.user, this.group, this.other, this.path

  void _chmod(int permission, String path) {
    if (!exists(path)) {
      throw ChModException('The file at ${truepath(path)} does not exists');
    }
    if (!Platform.isWindows) {
      'chmod $permission "$path"'.run;
    }
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
}
