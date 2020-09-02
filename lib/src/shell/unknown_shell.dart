import 'dart:io';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/macosx_installer.dart';
import '../installers/windows_installer.dart';
import 'shell_mixin.dart';

/// Used by dcli to interacte with the shell
/// environment when we are unable to detect
/// what shell is active.
/// This may simply be the parent process of the
/// dart app so not a shell at all.
class UnknownShell with ShellMixin {
  /// Name of the shell
  static const String shellName = 'Unknown';

  @override
  final int pid;

  /// the name of the process
  final String processName;

  UnknownShell.withPid(this.pid, {this.processName});

  @override
  bool addToPATH(String path) {
    if (Settings().isMacOS) {
      return addPathToMacOsPathd(path);
    } else if (Settings().isLinux) {
      return _addPathToLinuxPATH(path);
    } else {
      return false;
    }
  }

  ///
  bool addPathToMacOsPathd(String path) {
    var success = false;
    if (!isOnPATH(path)) {
      var macOSPathPath = join(rootPath, 'etc', 'path.d');

      try {
        if (!exists(macOSPathPath)) {
          createDir(macOSPathPath, recursive: true);
        }
        if (exists(macOSPathPath)) {
          join(macOSPathPath, 'dcli').write(path);
        }
        success = true;
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dcli/bin to path as we couldn't write to $macOSPathPath"));
      }
    }
    return success;
  }

  bool _addPathToLinuxPATH(String path) {
    var success = false;
    if (!isOnPATH(path)) {
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
            "Unable to add dcli/bin to path as we couldn't write to $profile"));
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
  String get pathToStartScript => null;

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
      return LinuxDCliInstaller().install();
    } else if (Settings().isWindows) {
      return WindowsDCliInstaller().install();
    } else if (Platform.isMacOS) {
      return MacOsxDCliInstaller().install();
    } else {
      throw UnsupportedError('Unsupported OS. ${Platform.operatingSystem}');
    }
  }

  @override
  String checkInstallPreconditions() {
    return null;
  }
}
