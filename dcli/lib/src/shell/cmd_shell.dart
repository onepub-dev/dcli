import '../../dcli.dart';
import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class CmdShell with WindowsMixin, ShellMixin {
  /// Attached to a command shell with the given
  CmdShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'cmd.exe';

  @override
  final int? pid;

  @override
  bool addToPATH(String path) => true;

  @override
  void addFileAssocation(String dcliPath) {
    super.addFileAssociation(dcliPath);
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isPrivilegedUser {
    final lines = 'net session'.toList(nothrow: true);
    if (lines.isNotEmpty && lines[0].contains('System error 5 has occurred.')) {
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
  bool operator ==(covariant CmdShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  @override
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;
}
