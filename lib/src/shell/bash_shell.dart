import '../../dcli.dart';
import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class BashShell with ShellMixin, PosixShell {
  /// Attached to a bash shell with the given pid.
  BashShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'bash';

  @override
  final int? pid;

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

      if (!exists(startFile)) {
        touch(startFile, create: true);
      }
      startFile.append(command);

      if (!quiet) {
        print('dcli tab completion installed. '
            'Restart your terminal to activate it.');
      }
    }
  }

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => appendToPATH(path);

  /// Appends the given path to the bash path if it isn't
  /// already on the path.
  @override
  bool appendToPATH(String path) {
    // ignore: flutter_style_todos
    /// TODO: check if there is already an export
    /// for dcli path.
    if (!isOnPATH(path)) {
      final export = 'export PATH=\$PATH:$path';
      _updatePATH(export);
    }
    return true;
  }

  /// Prepends the given path to the bash path if it isn't
  /// already on the path.
  @override
  bool prependToPATH(String path) {
    if (!isOnPATH(path)) {
      final export = 'export PATH=$path:\$PATH';
      _updatePATH(export);
    }
    return true;
  }

  void _updatePATH(String export) {
    final rcPath = pathToStartScript;

    if (!exists(rcPath)) {
      rcPath.write(export);
    } else {
      rcPath.append(export);
    }
  }

  /// Returns true if the dcil_complete has
  /// been installed as a bash auto completer
  @override
  bool get isCompletionInstalled {
    var completeInstalled = false;
    final startFile = pathToStartScript;

    if (exists(startFile)) {
      read(startFile).forEach((line) {
        if (line.contains('dcli_complete')) {
          completeInstalled = true;
        }
      });
    }

    return completeInstalled;
  }

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => '.bashrc';

  @override
  String get pathToStartScript => join(HOME, startScriptName);

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
