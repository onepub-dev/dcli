/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/mac_os_installer.dart';
import '../installers/windows_installer.dart';
import 'shell_mixin.dart';

/// Used by dcli to interacte with the shell
/// environment when we are unable to detect
/// what shell is active.
/// This may simply be the parent process of the
/// dart app so not a shell at all.
class UnknownShell with ShellMixin {
  /// Attached to the Unknown shell with the given pid.
  UnknownShell.withPid(this.pid, {this.processName});

  /// The name of the shell process.
  final String? processName;

  /// Name of the shell
  static const String shellName = 'Unknown';

  @override
  final int? pid;

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => true;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => false;

  @override
  bool appendToPATH(String path) {
    if (Settings().isMacOS) {
      return appendPathToMacOsPathd(path);
    } else if (Settings().isLinux) {
      return _appendToLinuxPath(path);
    } else {
      return false;
    }
  }

  @override
  bool prependToPATH(String path) {
    if (Settings().isMacOS) {
      return false;
    } else if (Settings().isLinux) {
      return _prependToLinuxPath(path);
    } else {
      return false;
    }
  }

  ///
  bool appendPathToMacOsPathd(String path) {
    var success = false;
    if (!isOnPATH(path)) {
      final macOSPathPath = join(rootPath, 'etc', 'path.d');

      try {
        if (!exists(macOSPathPath)) {
          createDir(macOSPathPath, recursive: true);
        }
        if (exists(macOSPathPath)) {
          join(macOSPathPath, 'dcli${const Uuid().v4()}').write(path);
        }
        success = true;
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(
          red(
            "Unable to add $path to path as we couldn't write "
            'to $macOSPathPath',
          ),
        );
      }
    }
    return success;
  }

  bool _appendToLinuxPath(String newPath) {
    final export = 'export PATH=\$PATH:$newPath';
    return _updateLinuxPath(newPath, export);
  }

  bool _prependToLinuxPath(String newPath) {
    final export = 'export PATH=\$PATH:$newPath';
    return _updateLinuxPath(newPath, export);
  }

  bool _updateLinuxPath(String path, String export) {
    var success = false;
    if (!isOnPATH(path)) {
      final profile = join(HOME, '.profile');
      try {
        if (exists(profile)) {
          if (!read(profile).toList().contains(export)) {
            profile.append(export);
            success = true;
          }
        }
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(
          red(
            "Unable to add dcli/bin to path as we couldn't write to $profile",
          ),
        );
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
  bool operator ==(covariant UnknownShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => true;

  @override
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  @override
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;

  @override
  bool get isPrivilegedUser => false;

  @override
  String? get loggedInUser =>
      'root'; // handles running in Docker with no shell.

  @override
  String privilegesRequiredMessage(String app) =>
      'You need to be a privileged user to run $app';

  @override
  Future<bool> install({bool installDart = false, bool activate = true}) async {
    if (core.Settings().isLinux) {
      return LinuxDCliInstaller().install(installDart: installDart);
    } else if (Settings().isWindows) {
      return WindowsDCliInstaller().install(installDart: installDart);
    } else if (core.Settings().isMacOS) {
      return MacOSDCliInstaller().install(installDart: installDart);
    } else {
      throw UnsupportedError('Unsupported OS. ${Platform.operatingSystem}');
    }
  }

  @override
  String? checkInstallPreconditions() => null;

  @override
  bool get isSudo => throw UnimplementedError();

  @override
  void releasePrivileges() {
    // no op.
    verbose(() => 'releasePrivileges called on UnknownShell. ignored');
  }

  @override
  void restorePrivileges() {
    // no op.
    verbose(() => 'releasePrivileges called on UnknownShell. ignored');
  }

  @override
  void withPrivileges(RunPrivileged action, {bool allowUnprivileged = false}) {
    verbose(() => 'withPrivileges called on UnknownShell. '
        'action called with no privilege changes.');

    restorePrivileges();
    action();
    releasePrivileges();
  }

  @override
  Future<void> withPrivilegesAsync(RunPrivilegedAsync action,
      {bool allowUnprivileged = false}) async {
    verbose(() => 'withPrivileges called on UnknownShell. '
        'action called with no privilege changes.');

    restorePrivileges();
    await action();
    releasePrivileges();
  }

  @override
  bool get isPrivilegedProcess => throw UnimplementedError();

  @override
  bool get isPrivilegedPasswordRequired => throw UnimplementedError();

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }

  @override
  String get installInstructions {
    if (core.Settings().isWindows) {
      return 'Run dcli install';
    } else {
      return r'''
Run:
sudo env PATH="$PATH" dcli install
''';
    }
  }
}
