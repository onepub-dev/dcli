import '../../dshell.dart';
import 'posix_mixin.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dshell needs to interact with the Bash shell.

class BashShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'bash';

  @override
  String get startScriptPath {
    return join(HOME, startScriptName);
  }

  @override
  bool get isCompletionSupported => true;

  // adds bash cli completion for dshell
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion() {
    if (!isCompletionInstalled) {
      // Add cli completion
      var command = "complete -C 'dshell_complete' dshell";

      var startFile = startScriptPath;

      if (startFile != null) {
        if (!exists(startFile)) {
          touch(startFile, create: true);
        }
        startFile.append(command);

        print(
            'dshell tab completion installed. Restart your terminal to activate it.');
      } else {
        printerr(red('Unable to install dshell tab completion'));
        printerr(
            "Add ${orange('$command')} to your start up script to enable tab completion");
      }
    }
  }

  @override
  String get name => shellName;

  @override
  String get startScriptName {
    return '.bashrc';
  }
}
