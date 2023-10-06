/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:posix/posix.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/mac_os_installer.dart';
import 'macos_utils.dart';

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

    final String pathToHome;

    if (Platform.isMacOS) {
      pathToHome = MacOSUtils.loggedInUsersHome(user);
    } else {
      final parts = 'getent passwd $user'.firstLine!.split(':');

      pathToHome = parts[5];
    }
    return pathToHome;
  }

  late final Immutable<UserEnvironment> priviledgedUser = Immutable();
  late final Immutable<UserEnvironment> nonPriviledgedUser = Immutable();

  /// revert uid and gid to original user's id's
  /// You should note that your PATH will still be
  /// the SUDO PATH not your original user's PATH.
  void releasePrivileges() {
    verbose(() => 'releasePrivileges called');
    if (Shell.current.isPrivilegedUser) {
      priviledgedUser.setIf(UserEnvironment.save);

      nonPriviledgedUser
        ..setIf(() => UserEnvironment.preSudo(pathToHome: loggedInUsersHome))
        ..runIf((user) {
          verbose(() => 'release - builer');
          initgroups(user.username);
          user.build();
        });
    }
  }

  /// If a prior call to [releasePrivileges] has
  /// been made then this command will restore
  /// those privileges
  /// If releasePrivileges hasn't been called then
  /// this method does nothing.
  void restorePrivileges() {
    verbose(() => 'restorePrivileges called');
    priviledgedUser.runIf((user) {
      verbose(() => 'restore - builer');
      user.build();
      initgroups(user.username);
    });
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
  Future<bool> install({bool installDart = false, bool activate = true}) async {
    var installed = false;
    if (core.Settings().isLinux) {
      installed = await LinuxDCliInstaller().install(installDart: installDart);
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

class UserEnvironment {
  // Save the details of the current user environment
  UserEnvironment.save() {
    username = _whoami();
    gid = getgid();
    uid = getuid();
    pathToHome = HOME;
    pathToShell = env['SHELL'];
  }

  /// Creates a [UserEnvironment] from the SUDO env args
  /// that describe the pre-sudo user.
  UserEnvironment.preSudo({required this.pathToHome}) {
    // get the details of the user, pre-sudo starting.
    final sUID = env['SUDO_UID'];
    final gUID = env['SUDO_GID'];

    // convert id's to integers.
    gid = gUID != null ? int.tryParse(gUID) ?? 0 : 0;
    uid = sUID != null ? int.tryParse(sUID) ?? 0 : 0;

    // CONSIDER: throw an exception if we can't determine the opre-sudo
    // user?
    username = env['SUDO_USER'] ?? env['USER'] ?? '';

    pathToShell = env['SHELL'];
  }

  late final String username;

  /// we cache the real uid and gid
  /// when we release privileges so we can restore them.
  late final int gid;
  late final int uid;

  /// The path to the original privileged users home dir.
  late final String pathToHome;

  // path to the active shell e.g. /bin/bash
  late final String? pathToShell;

  /// Build the user environment
  void build() {
    // // [initgroups] can only be called when we are root
    // // so depending on which direction we are moving the
    // // users privilieges we need to call this before
    // // or after changing the uid.
    // if (uid == 0) {
    //   initgroups(username);
    // }

    // shells like bash/zsh reset the euid to the uid
    // to descalate priviliges.
    // This results in the euid being reset to sudo (0)
    // so to stop this we need to ensure a real uid/gid
    // are actually the original user not sudo.
    // This fits nicely with our principle that when a user
    // calls [releasePrivileges] the script should fully
    // appear to not have been run as sudo.
    verbose(() => '''
Building user enviroment
username: $username
HOME: $pathToHome
USER: $username
LOGNAME: $username
SHELL: ${env['SHELL']}
gid:  $gid
uid:  $uid''');

    // reorder(() => uid == 0, () => setuid(uid), () => setgid(gid));

    reorder(() => uid == 0, () => seteuid(uid), () => setegid(gid));

    env['HOME'] = pathToHome;
    env['USER'] = username;
    env['LOGNAME'] = username;
    env['SHELL'] = pathToShell;
  }

  void reorder(
      bool Function() condition, void Function() one, void Function() two) {
    if (condition() == true) {
      one();
      two();
    } else {
      two();
      one();
    }
  }
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

class Immutable<T> {
  Immutable();

  T? wrapped;

  // stores [wrapped] if [setIf] hasn't already been called
  void setIf(T Function() wrapped) {
    this.wrapped ??= wrapped();
  }

  /// Runs [action] if [setIf] has been called
  void runIf(void Function(T wrapped) action) {
    final stack = Trace.current();
    verbose(() => 'runIf $stack');
    if (wrapped != null) {
      action(wrapped as T);
    }
  }
}
