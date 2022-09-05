import '../../dcli.dart';
import '../settings.dart';
import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class PowerShell with WindowsMixin, ShellMixin {
  /// Attached to the Powershell shell with the given pid.
  PowerShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'powershell.exe';

  @override
  final int? pid;

  @override
  bool addToPATH(String path) => true;

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isPrivilegedUser {
    final currentPrincipal =
        // ignore: lines_longer_than_80_chars
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    verbose(() => 'currentPrinciple: $currentPrincipal');
    final isPrivileged =
        // ignore: lines_longer_than_80_chars
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
                .firstLine ??
            'false';
    verbose(() => 'isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  @override
  bool get isPrivilegedProcess => isPrivilegedUser;

  @override
  void addFileAssocation(String dcliPath) {
    super.addFileAssociation(dcliPath);
  }

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant PowerShell other) => name == other.name;

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
