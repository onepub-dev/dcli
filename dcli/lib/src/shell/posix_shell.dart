/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:posix/posix.dart';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/mac_os_installer.dart';

/// Provides a number of helper functions
/// for posix based shells.
///
/// You would normally access these methods via:
///
/// ```dart
/// Shell.current;
/// ```
///
/// Occasionally you might need to access some posix specific
/// functionality in which case (assuming you are running a posix shell)
/// you can use:
///
/// ```dart
/// (Shell.current as PosixShell);
/// ```
mixin PosixShell {
  /// True if the processes effictive uid is root.
  bool get isPrivilegedUser {
    final euid = geteuid();
    verbose(() => 'isPrivilegedUser: euid=$euid');
    return euid == 0;
    // final user = _whoami();
    // final privileged = user == 'root';
    // verbose(() => 'isPrivilegedUser: $privileged');
    // return privileged;
  }

  /// Returns true if running a privileged action would
  /// cause a password to be requested.
  ///
  /// Linux/MacOS: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired {
    if (isPrivilegedUser) {
      return false;
    }
    final response = 'sudo -nv'.toList(nothrow: true);

    return response.isNotEmpty &&
        response.first == 'sudo: a password is required';
  }

  /// True if the processes real uid is root.
  bool get isPrivilegedProcess {
    final uid = getuid();
    verbose(() => 'isPrivilegedProcess: uid=$uid');
    return uid == 0;
  }

  /// returns the username of the logged in user.
  String get loggedInUser {
    var user = _whoami();
    if (user == 'root') {
      user = env['SUDO_USER'] ?? 'root';
    }
    verbose(() => 'loggedInUser: $user');
    return user;
  }

  /// Attempts to retrive the logged in user's home directory.
  ///
  /// This is intended when a script is run as sudo and we need
  /// to get the home directory of the original user.
  String get loggedInUsersHome {
    final user = loggedInUser;

    final parts = 'getent passwd $user'.firstLine!.split(':');

    final pathToHome = parts[5];

    return pathToHome;
  }

  String _whoami() {
    String? user;
    if (isPosixSupported) {
      try {
        user = getlogin();
      } on PosixException catch (e) {
        if (e.code == ENXIO) {
          // no controlling terminal so we must be root.
          user = 'root';
        }
      }
    }

    /// fall back to whoami if nothing else works.
    user ??= 'whoami'.firstLine;
    verbose(() => 'whoami: $user');
    return user!;
  }

  /// we cache the real uid and gid
  /// when we release privileges so we can restore them.
  late final int? _rgid;
  late final int? _ruid;

  /// revert uid and gid to original user's id's
  /// You should note that your PATH will still be
  /// the SUDO PATH not your original user's PATH.
  void releasePrivileges() {
    if (Shell.current.isPrivilegedUser) {
      // get the user details pre-sudo starting.
      final sUID = env['SUDO_UID'];
      final gUID = env['SUDO_GID'];

      // convert id's to integers.
      final originalUID = sUID != null ? int.tryParse(sUID) ?? 0 : 0;
      final originalGID = gUID != null ? int.tryParse(gUID) ?? 0 : 0;

      // CONSIDER: throw an exception if we can't determine originalUser?
      final originalUser = env['SUDO_USER'] ?? env['USER'] ?? '';

      _rgid ??= getgid();
      _ruid ??= getuid();

      _resetUserEnvironment(originalUser, originalGID, originalUID);

      initgroups(originalUser);
      setegid(originalGID);
      seteuid(originalUID);

      // shells like bash/zsh reset the euid to the uid
      // to descalate priviliges.
      // This results in the euid being reset to sudo (0)
      // so to stop this we need to ensure a real uid/gid
      // are actually the original user not sudo.
      // This fits nicely with our principle that when a user
      // calls [releasePrivileges] the script should fully
      // appear to not have been run as sudo.
      setgid(originalGID);
      setuid(originalUID);

      verbose(() => 'egid: $originalGID ${getegid()}');
      verbose(() => 'euid: $originalUID ${geteuid()}');
      verbose(() => 'gid: $originalGID $_rgid');
      verbose(() => 'uid: $originalUID $_ruid');
    }
  }

  /// If a prior call to [releasePrivileges] has
  /// been made then this command will restore
  /// those privileges
  void restorePrivileges() {
    _resetUserEnvironment('root', 0, 0);
    setegid(0);
    seteuid(0);

    if (_rgid != null) {
      setgid(_rgid!);
    }
    if (_ruid != null) {
      setuid(_ruid!);
    }
    initgroups('root');
  }

  void _resetUserEnvironment(
      String originalUser, int originalGID, int originalUID) {
    final passwd = getPassword(originalUser);
    env['HOME'] = passwd.homePathTo;
    env['SHELL'] = passwd.shellPathTo;

    env['USER'] = originalUser;
    env['LOGNAME'] = originalUser;
  }

  /// Run [action] with root UID and gid
  void withPrivileges(RunPrivileged action, {bool allowUnprivileged = false}) {
    final startedPriviledged = Shell.current.isPrivilegedProcess;
    if (!allowUnprivileged && !startedPriviledged) {
      throw ShellException(
        'You can only use withPrivileges when running as a privileged user.',
      );
    }
    final isprivileged = geteuid() == 0;

    if (!isprivileged && startedPriviledged) {
      restorePrivileges();
    }

    action();

    /// If the code was originally running privileged then
    /// we leave it as it was.
    if (!isprivileged && startedPriviledged) {
      releasePrivileges();
    }
  }

  /// Returns true if we are currently running under sudo.
  bool get isSudo => !Settings().isWindows && env['SUDO_USER'] != null;

  /// The message used during installation if it needs to be run with sudo.
  String privilegesRequiredMessage(String app) => installInstructions;

  /// Install dart/dcli
  bool install({bool installDart = false, bool activate = true}) {
    var installed = false;
    if (core.Settings().isLinux) {
      installed = LinuxDCliInstaller().install(installDart: installDart);
    } else {
      installed = MacOSDCliInstaller().install(installDart: installDart);
    }

    // DartProject.self.compile(install: true, overwrite: true);

    // addFileAssocation(binPath);

    // if (isCompletionSupported) {
    //   if (!isCompletionInstalled) {
    //     installTabCompletion();
    //   }
    // }

    // if (isPrivilegedUser) {
    //   _symlinkDCli(dcliPath);
    // }

    return installed;
  }

  /// at this point no posix system has any preconditions.
  String? checkInstallPreconditions() => null;

  /// Returns the instructions to install DCli.
  String get installInstructions => r'''
Run:
sudo env PATH="$PATH" dcli install
''';

  /// Symlink so dcli works under sudo.
  /// We use the location of dart exe and add dcli symlink
  /// to the same location.
  // ignore: unused_element
  void _symlinkDCli(String dcliPath) {
    if (!core.Settings().isWindows) {
      final linkPath = join(dirname(DartSdk().pathToDartExe!), 'dcli');
      if (isPrivilegedPasswordRequired && !isWritable(linkPath)) {
        print('Enter the sudo password when prompted.');
      }

      'ln -sf $dcliPath $linkPath'.start(privileged: !isWritable(linkPath));
      // symlink(dcliPath, linkPath);
    }
  }
}
