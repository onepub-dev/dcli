import '../../dcli.dart';
import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class CmdShell with WindowsMixin, ShellMixin {
  /// Name of the shell
  static const String shellName = 'cmd.exe';

  @override
  final int? pid;
  CmdShell.withPid(this.pid);

  @override
  bool addToPATH(String path) {
    /// These need to be run as admin
    /// not working correctly at this point.
    /// Looks like powershell ignores the file association.
    'cmd /c assoc .dart=dcli'.run;
    r'''cmd /c ftype dcli=`"C:\Users\User\dcli`" `"%1`" `"%2`" `"%3`" `"%4`" `"%5`" `"%6`" `"%7`" `"%8`" `"%9`"'''
        .run;
    return true;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isPrivilegedUser {
    final lines = 'net session'.toList(nothrow: true);
    if (lines.isNotEmpty && lines[0]!.contains('System error 5 has occured.')) {
      return false;
    }

    return true;
  }

  @override
  bool get isPrivilegedProcess => isPrivilegedUser;

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant CmdShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName => throw UnimplementedError;

  @override
  String get pathToStartScript => throw UnimplementedError;
}
