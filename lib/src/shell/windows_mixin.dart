/// import 'dart:ffi';

// import 'package:ffi/ffi.dart';
// import 'package:win32/win32.dart';

import '../../dcli.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';

/// Common code for Windows shells.
mixin WindowsMixin {
  /// Check if the shell has any notes re: pre-isntallation conditions.
  String? checkInstallPreconditions() => null;

  /// Windows 10+ has a developer mode that needs to be enabled to create
  ///  symlinks without escalated prividedges.
  /// For details on enabling dev mode on windows see:
  /// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
  bool inDeveloperMode() {
    /// Example result:
    /// <blank line>
    /// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock
    /// AllowDevelopmentWithoutDevLicense    REG_DWORD    0x1
    final response =
        r'reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense"'
            .toList(runInShell: true, skipLines: 2)
            .first;
    final parts = response.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) {
      throw InstallException('Unable to obtain development mode settings');
    }

    return parts[2] == '0x1';
  }

  /// Called to install the windows specific dart/dcli components.
  bool install({bool installDart = true}) =>
      WindowsDCliInstaller().install(installDart: installDart);

  ///
  String privilegesRequiredMessage(String app) =>
      'You need to be a privileged user to run $app';

  ///
  String? get loggedInUser => env['USERNAME'];

  /// revert uid and gid to original user's id's
  void releasePrivileges() {
    /// NO OP under windows as its not possible and not needed.
  }

  /// Run [privilegedCallback] with root UID and gid
  void withPrivileges(RunPrivileged privilegedCallback) {
    if (!Shell.current.isPrivilegedUser) {
      throw ShellException(
          'You can only use withPrivileges when running as a privileged user.');
    }
    privilegedCallback();
  }

  /// On Windows this is always false.
  bool get isSudo => false;

  // TODO(bsutton): impement notification so desktop apps
  // update their environment.
  /// Updatest the PATH environment variable.
  static void setPath(List<String?> paths) {
    // // const char * what = "Environment";
    // // DWORD rv;
    // // SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
    // // 						(LPARAM) what, SMTO_ABORTIFHUNG, 5000, & rv );
    // _setRegistryValue(HKEY_CURRENT_USER, "Environment", "PATH",
    //     paths.join(Env().delimiterForPATH));
  }

  // // Update a windows value.
  // static void _setRegistryValue(
  //     int key, String subKey, String valueName, String value) {
  //   /// RegOpenKeyEx
  //   final subKeyPtr = TEXT(subKey);
  //   final openKeyPtr = allocate<IntPtr>();

  //   // RegSetValueEx
  //   final valueNamePtr = TEXT(valueName);
  //   final valuePtr = TEXT(value);
  //   final dataType = allocate<Uint32>()..value = REG_EXPAND_SZ;

  //   final data = allocate<Uint8>(count: value.length + 1);
  //   final dataSize = allocate<Uint32>()..value = value.length + 1;

  //   try {
  //     var result = RegOpenKeyEx(key, subKeyPtr, 0
  //      , REG_EXPAND_SZ, openKeyPtr);
  //     if (result == ERROR_SUCCESS) {
  //       result = RegSetValueEx(openKeyPtr.value, valueNamePtr, nullptr,
  //           dataType, valuePtr.cast(), dataSize);

  //       // ignore: invariant_booleans
  //       if (result != ERROR_SUCCESS) {
  //         throw WindowsException(HRESULT_FROM_WIN32(result));
  //       }
  //     } else {
  //       throw WindowsException(HRESULT_FROM_WIN32(result));
  //     }
  //   } finally {
  //     free(subKeyPtr);
  //     free(valueNamePtr);
  //     free(openKeyPtr);
  //     free(data);
  //     free(dataSize);
  //   }
  //   RegCloseKey(openKeyPtr.value);
  // }
}
