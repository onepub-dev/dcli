// @dart=3.0

import 'package:dcli_core/dcli_core.dart';

import '../../shell/shell.dart';
import '../environment.dart';

class ProcessSettings {
  ProcessSettings(this.command,
      {this.args = const <String>[],
      String? workingDirectory,
      this.runInShell = false,
      this.detached = false,
      this.terminal = false,
      this.privileged = false,
      this.extensionSearch = true,
      ProcessEnvironment? environment})
      : environment = environment ?? ProcessEnvironment() {
    this.workingDirectory = workingDirectory ??= pwd;

    /// If privileged has been requested we pass
    /// the privileged status of the user across
    /// as the Shell details will probably cached in this
    /// isolate but not the called isolate.
    if (privileged) {
      isPriviledgedUser = Shell.current.isPrivilegedUser;
    }
  }

  final String command;
  final List<String> args;
  late final String workingDirectory;

  // environment variables
  ProcessEnvironment environment;

  bool runInShell = false;
  bool detached = false;
  bool terminal = false;
  bool privileged = false;
  bool extensionSearch = true;

  bool isPriviledgedUser = false;

  /// If we are running with mode terminal or detached then
  /// we don't have access to the stdio streams.
  bool get hasStdio => !(terminal | detached);
}
