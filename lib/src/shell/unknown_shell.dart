import 'dart:io';

import '../../dshell.dart';
import '../installers/linux_installer.dart';
import '../installers/macosx_installer.dart';
import '../installers/windows_installer.dart';
import 'shell_mixin.dart';

/// Used by dshell to interacte with the shell
/// environment when we are unable to detect
/// what shell is active.
/// This may simply be the parent process of the
/// dart app so not a shell at all.
class UnknownShell with ShellMixin {
  /// Name of the shell
  static const String shellName = 'Unknown';

  /// the name of the process
  final String processName;

  ///
  UnknownShell(this.processName);

  @override
  bool addToPath(String path) {
    if (Settings().isMacOS) {
      return addPathToMacOsPathd(path);
    } else if (Settings().isLinux) {
      return _addPathToLinuxPath(path);
    } else {
      return false;
    }
  }

  ///
  bool addPathToMacOsPathd(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var macOSPathPath = join(rootPath, 'etc', 'path.d');

      try {
        if (!exists(macOSPathPath)) {
          createDir(macOSPathPath, recursive: true);
        }
        if (exists(macOSPathPath)) {
          join(macOSPathPath, 'dshell').write(path);
        }
        success = true;
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $macOSPathPath"));
      }
    }
    return success;
  }

  bool _addPathToLinuxPath(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var profile = join(HOME, '.profile');
      try {
        if (exists(profile)) {
          var export = 'export PATH=\$PATH:$path';
          if (!read(profile).toList().contains(export)) {
            profile.append(export);
            success = true;
          }
        }
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $profile"));
      }
    }
    return success;
  }

  @override
  void installTabCompletion({bool quiet = false}) => throw UnimplementedError();

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant UnknownShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String get startScriptName => throw UnimplementedError;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptPath => null;

  @override
  bool get isPrivilegedUser => false;

  @override
  String get loggedInUser => null;

  @override
  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }

  @override
  bool install() {
    if (Platform.isLinux) {
      return LinuxDShellInstaller().install();
    } else if (Platform.isWindows) {
      return WindowsDShellInstaller().install();
    } else if (Platform.isMacOS) {
      return MacOsxDshellInstaller().install();
    } else {
      throw UnsupportedError('Unsupported OS. ${Platform.operatingSystem}');
    }
  }

  @override
  String checkInstallPreconditions() {
    return null;
  }
}
