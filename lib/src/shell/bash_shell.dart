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
  bool get isCompletionSupported => true;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion({bool quiet = false}) {
    if (!isCompletionInstalled) {
      // Add cli completion
      /// -o nospace - after directory names

      const command = "complete -o nospace -C 'dcli_complete' dcli";

      final startFile = pathToStartScript;

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
            "Add ${orange(command)} to your start up script to enable tab completion");
      }
    }
  }

  /// Adds the given path to the bash path if it isn't
  /// already on teh path.
  @override
  bool addToPATH(String path) {
    if (!isOnPATH(path)) {
      final export = 'export PATH=\$PATH:$path';

      final rcPath = pathToStartScript;

      if (!exists(rcPath)) {
        rcPath.write(export);
      } else {
        rcPath.append(export);
      }
    }
    return true;
  }

  @override
  bool get isCompletionInstalled {
    var completeInstalled = false;
    final startFile = pathToStartScript;

    if (startFile != null) {
      if (exists(startFile)) {
        read(startFile).forEach((line) {
          if (line.contains('dcli_complete')) {
            completeInstalled = true;
          }
        });
      }
    }
    return completeInstalled;
  }

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName {
    return '.bashrc';
  }

  @override
  String get pathToStartScript {
    return join(HOME, startScriptName);
  }
}
