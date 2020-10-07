import '../../dcli.dart';
import 'posix_mixin.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class BashShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'bash';

  @override
  final int pid;
  BashShell.withPid(this.pid);

  @override
  String get pathToStartScript {
    return join(HOME, startScriptName);
  }

  @override
  bool get isCompletionSupported => true;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion({bool quiet = false}) {
    if (!isCompletionInstalled) {
      // Add cli completion
      /// -o nospace - after directory names

      var command = "complete -o nospace -C 'dcli_complete' dcli";

      var startFile = pathToStartScript;

      if (startFile != null) {
        if (!exists(startFile)) {
          touch(startFile, create: true);
        }
        startFile.append(command);

        if (!quiet) {
          print(
              'dcli tab completion installed. Restart your terminal to activate it.');
        }
      } else {
        printerr(red('Unable to install dcli tab completion'));
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

  @override
  bool get hasStartScript => true;
}
