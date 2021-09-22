import 'dart:ffi';

import 'package:win32/win32.dart';

import '../../dcli.dart';
import '../ffi/with_memory.dart';
import '../installers/windows_installer.dart';
import '../platform/windows/registry.dart';

/// Common code for Windows shells.
mixin WindowsMixin {
  /// Check if the shell has any notes re: pre-isntallation conditions.
  String? checkInstallPreconditions() => null;

  /// Windows 10+ has a developer mode that needs to be enabled to create
  ///  symlinks without escalated prividedges.
  /// For details on enabling dev mode on windows see:
  /// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
  bool inDeveloperMode() {
    final response = regGetDWORD(
      HKEY_LOCAL_MACHINE,
      r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
      'AllowDevelopmentWithoutDevLicense',
    );

    return response == 1;
  }

  /// Called to install the windows specific dart/dcli components.
  bool install({bool installDart = true}) =>
      WindowsDCliInstaller().install(installDart: installDart);

  ///
  String privilegesRequiredMessage(String app) =>
      'You need to be an Administrator to run $app';

  /// Returns true if running a privileged action woulduser
  /// cause a password to be requested.
  ///
  /// Linux/MacOS: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired => false;

  /// Adds a path to the start script
  /// returns true if adding the path was successful
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => appendToPATH(path);

  /// Appends [path] to the end of the PATH
  /// by updating the Windows Registry.
  /// We update the user's PATH (HKEY_CURRENT_USER) rather
  /// than the system path so this change will only
  /// affect the logged in user.
  ///
  /// Note: this doesn't update current scripts
  /// PATH.
  ///
  /// In almost all shells you will need to restart
  /// the terminal in order for the path change to take affect.
  bool appendToPATH(String path) {
    regAppendToPath(path);
    return true;
  }

  /// Prepend [path] to the end of the PATH
  /// by updating the Windows Registry.
  /// We update the user's PATH (HKEY_CURRENT_USER) rather
  /// than the system path so this change will only
  /// affect the logged in user.
  ///
  /// Note: this doesn't update current scripts
  /// PATH.
  ///
  /// In almost all shells you will need to restart
  /// the terminal in order for the path change to take affect.
  bool prependToPATH(String path) {
    regPrependToPath(path);
    return true;
  }

  ///
  String? get loggedInUser => env['USERNAME'];

  /// Attempts to retrive the logged in user's home directory.
  String get loggedInUsersHome {
    final drive = env['HOMEDRIVE'];
    final path = env['HOMEPATH'];

    return '$drive$path';
  }

  /// NO OP under windows
  void releasePrivileges() {
    /// NO OP under windows as its not possible and not needed.
  }

  /// NO OP under windows
  void restorePrivileges() {
    /// NO OP under windows as its not possible and not needed.
  }

  /// Run [action] with root UID and gid
  void withPrivileges(RunPrivileged action) {
    if (!Shell.current.isPrivilegedUser) {
      throw ShellException(
        'You can only use withPrivileges when running as a privileged user.',
      );
    }
    action();
  }

  /// On Windows this is always false.
  bool get isSudo => false;

  /// Returns the instructions to install DCli.
  String get installInstructions => 'Run dcli install';

  /// Returns true if the current process is running with elevated privileges
  /// e.g. Is running as an Administrator.
  bool get isPrivilegedUser {
    var isElevated = false;

    withMemory<void, Uint32>(sizeOf<Uint32>(), (phToken) {
      withMemory<void, Uint32>(sizeOf<Uint32>(), (pReturnedSize) {
        withMemory<void, _TokenElevation>(sizeOf<_TokenElevation>(),
            (pElevation) {
          if (OpenProcessToken(
                GetCurrentProcess(),
                TOKEN_QUERY,
                phToken.cast(),
              ) ==
              1) {
            if (GetTokenInformation(
                  phToken.value,
                  TOKEN_INFORMATION_CLASS.TokenElevation,
                  pElevation,
                  sizeOf<_TokenElevation>(),
                  pReturnedSize,
                ) ==
                1) {
              isElevated = pElevation.ref.tokenIsElevated != 0;
            }
          }
          if (phToken.value != 0) {
            CloseHandle(phToken.value);
          }
        });
      });
    });
    return isElevated;
  }

  /// Returns true if the current process is running with elevated privileges
  /// e.g. Is running as an Administrator.
  bool get isPrivilegedProcess => isPrivilegedUser;
}

/// Native Windows stucture used to get the elevated
/// status of the current process.
class _TokenElevation extends Struct {
  /// A nonzero value if the token has elevated privileges;
  /// otherwise, a zero value.
  @Int32()
  external int tokenIsElevated;
}
