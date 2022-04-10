import 'package:win32/win32.dart';

import '../../dcli.dart';
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
  bool install({bool installDart = true, bool activate = true}) =>
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

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  bool get canModifyPath => true;

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
  void withPrivileges(RunPrivileged action, {bool allowUnprivileged = false}) {
    if (!allowUnprivileged && !Shell.current.isPrivilegedUser) {
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
  /// Revert to the lower version for 2.16
  bool get isPrivilegedUser {
    final currentPrincipal =
        // ignore: lines_longer_than_80_chars
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    verbose(() => 'currentPrinciple: $currentPrincipal');
    final isPrivileged =
        // ignore: lines_longer_than_80_chars
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
                .firstLine ??
            'false';
    verbose(() => 'isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  // bool get isPrivilegedUser {
  //   var isElevated = false;

  //   withMemory<void, Uint32>(sizeOf<Uint32>(), (phToken) {
  //     withMemory<void, Uint32>(sizeOf<Uint32>(), (pReturnedSize) {
  //       withMemory<void, _TokenElevation>(sizeOf<_TokenElevation>(),
  //           (pElevation) {
  //         if (OpenProcessToken(
  //               GetCurrentProcess(),
  //               TOKEN_QUERY,
  //               phToken.cast(),
  //             ) ==
  //             1) {
  //           if (GetTokenInformation(
  //                 phToken.value,
  //                 TOKEN_INFORMATION_CLASS.TokenElevation,
  //                 pElevation,
  //                 sizeOf<_TokenElevation>(),
  //                 pReturnedSize,
  //               ) ==
  //               1) {
  //             isElevated = pElevation.ref.tokenIsElevated != 0;
  //           }
  //         }
  //         if (phToken.value != 0) {
  //           CloseHandle(phToken.value);
  //         }
  //       });
  //     });
  //   });
  //   return isElevated;
  // }

  /// Add a file association so that typing the name of a dart
  /// script on the cli launches dcli which in turn launches the script.
  ///
  /// ```bash
  /// main.dart
  /// > hello world
  /// ```
  /// https://docs.microsoft.com/en-us/windows/win32/shell/fa-file-types
  void addFileAssociation(String dcliPath) {
    const progIdPath = r'Software\Classes\.dart\OpenWithProgids';

    if (regKeyExists(HKEY_CURRENT_USER, progIdPath)) {
      regDeleteKey(HKEY_CURRENT_USER, progIdPath);
    }

    regCreateKey(HKEY_CURRENT_USER, progIdPath);

    regSetString(HKEY_CURRENT_USER, progIdPath, 'noojee.dcli', '');

    const commandPath = r'Software\Classes\noojee.dcli\shell\open\command';
    if (regKeyExists(HKEY_CURRENT_USER, commandPath)) {
      regDeleteKey(HKEY_CURRENT_USER, commandPath);
    }

    regCreateKey(HKEY_CURRENT_USER, commandPath);
    regSetString(
        HKEY_CURRENT_USER,
        commandPath,
        defaultRegistryValueName,
        '"${DCliPaths().pathToDCli}" '
        // the %* is meant to represent all parameters even if more than
        // 9 are passed. In my experiments it doesn't appear to pass more than
        // 8 (as %1 is already consumed)  and if fact makes no difference
        // to just using %1 in the following line. I have left it
        // in for now and may follow up later.
        '"%1"%*');
  }

  /// Add a file association so that typing the name of a dart
  /// script on the cli launches dcli which in turn launches the script.
  ///
  /// ```bash
  /// main.dart
  /// > hello world
  /// ```
  /// https://docs.microsoft.com/en-us/windows/win32/shell/fa-file-types
  void addFileAssociationv2() {
    // create a ProgID for dcli 'noojee.dcli'
    regSetString(HKEY_CLASSES_ROOT, '.dart', defaultRegistryValueName, 'dcli');

    // When you create or change a file association, it is important to notify
    //the system that you have made a change. Do so by calling SHChangeNotify
    // and specifying the SHCNE_ASSOCCHANGED event. If you do not call
    //SHChangeNotify, the change may not be recognized until after the system
    //is rebooted.
    // computer\hkey_classes_root\.dart\OpenWithProgids => default (not set),
    // VSCode.dart

    // create a ProgID for dcli 'noojee.dcli'
    regSetString(HKEY_CURRENT_USER, r'\Software\Classes\noojee.dcli',
        defaultRegistryValueName, 'dcli');

    // associate the .dart extension with dcli's prog id
    regSetString(HKEY_CURRENT_USER, r'\Software\Classes\.dart',
        defaultRegistryValueName, 'noojee.dcli');

    // regSetString(HKEY_CLASSES_ROOT, r'.dart\OpenWithProgids', 'dcli.bat', '');

    // computer\hkey_current_user\software\classes\.dart -> default (not set)
    regSetString(HKEY_CURRENT_USER, r'SOFTWARE\Classes\.dart\OpenWithProgids',
        'noojee.dcli.dart', '');

// computer\hkey_current_user\software\classes\.dart -> default (not set)
    regSetString(HKEY_LOCAL_MACHINE, r'SOFTWARE\Classes\.dart',
        defaultRegistryValueName, 'dcli');

    //computer\hkey_classes_root\dcli\shell\open\command
    //   -> Default C:\Users\Brett\AppData\Local\Pub\Cache\bin\dcli.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
    regSetExpandString(
        HKEY_CURRENT_USER,
        r'dcli\shell\open\command',
        defaultRegistryValueName,
        '${DCliPaths().pathToDCli}  %1 %2 %3 %4 %5 %6 %7 %8 %9');

    // computer\hkey_classes_root\.dart => dcli
    // regSetString(HKEY_CURRENT_USER, '.dart', defaultRegistryValueName
    //, 'dcli');

    // [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dart\OpenWithList]
    regSetString(
        HKEY_CURRENT_USER,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dart\OpenWithList',
        'a',
        'dcli.bat');

    /// to do check if there is any existing MRUentries
    /// and move them down unless
    /// they are for dcli
    regSetString(
        HKEY_CURRENT_USER,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dart',
        'MRUList',
        'a');

    // [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dart\OpenWithProgids]
    // "dcli"
    regSetNone(
        HKEY_CURRENT_USER,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dart\OpenWithProgids',
        'dcli');
  }

// Computer\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts
//   -> Applications\Code.exe_.dart

// Computer\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts
//  -> dcli_.dart
//  -> VSCode.dart_.dart

// Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.dart -> default not set

// https://stackoverflow.com/questions/69761/how-to-associate-a-file-extension-to-the-current-executable-in-c-sharp

// computer\hkey_classes_root\dcli\shell\open\command
//   -> Default C:\Users\Brett\AppData\Local\Pub\Cache\bin\dcli.bat %1 %2 %3 %4 %5 %6 %7 %8 %9

  /// Returns true if the current process is running with elevated privileges
  /// e.g. Is running as an Administrator.
  bool get isPrivilegedProcess => isPrivilegedUser;
}

/// Native Windows stucture used to get the elevated
/// status of the current process.
// class _TokenElevation extends Struct {
//   /// A nonzero value if the token has elevated privileges;
//   /// otherwise, a zero value.
//   @Int32()
//   external int tokenIsElevated;
// }
