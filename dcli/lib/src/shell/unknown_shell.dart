/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
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
  /// The name of the shell process.
  final String? processName;

  /// Name of the shell
  static const shellName = 'Unknown';

  @override
  final int? pid;

  /// Attached to the Unknown shell with the given pid.
  UnknownShell.withPid(this.pid, {this.processName});

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => true;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => false;

  /// @Throwing(ArgumentError)
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

  /// @Throwing(ArgumentError)
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
  /// @Throwing(ArgumentError)
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
      } catch (e) {
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

  /// @Throwing(ArgumentError)
  bool _appendToLinuxPath(String newPath) {
    final export = 'export PATH=\$PATH:$newPath';
    return _updateLinuxPath(newPath, export);
  }

  /// @Throwing(ArgumentError)
  bool _prependToLinuxPath(String newPath) {
    final export = 'export PATH=\$PATH:$newPath';
    return _updateLinuxPath(newPath, export);
  }

  /// @Throwing(ArgumentError)
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
      } catch (e) {
        printerr(
          red(
            "Unable to add dcli/bin to path as we couldn't write to $profile",
          ),
        );
      }
    }
    return success;
  }

  /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
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

  /// Throws [Type].
  /// @Throwing(Type)
  @override
  // good enough
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  /// Throws [Type].
  /// @Throwing(Type)
  @override
  // good enough
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;

  @override
  bool get isPrivilegedUser => false;

  @override
  String? get loggedInUser => 'root';

  @override
  String privilegesRequiredMessage(String app) =>
      'You need to be a privileged user to run $app';

  /// Throws [UnsupportedError].
  /// @Throwing(UnsupportedError)
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

  /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
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

  /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
  @override
  bool get isPrivilegedProcess => throw UnimplementedError();

  /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
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
