import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

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

  /// Returns true if running a privileged action would
  /// cause a password to be requested.
  ///
  /// Linux/OSX: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired => false;

  ///
  String? get loggedInUser => env['USERNAME'];

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
          'You can only use withPrivileges when running as a privileged user.');
    }
    action();
  }

  /// On Windows this is always false.
  bool get isSudo => false;

  // TODO(bsutton): impement notification so desktop apps
  // update their environment.
  /// Appends [newPath] to the PATH environment variable.
  static void appendToPath(String newPath) {
    // const char * what = "Environment";
    // DWORD rv;
    // SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
    // 						(LPARAM) what, SMTO_ABORTIFHUNG, 5000, & rv );

    final paths = getRegistryList(HKEY_CURRENT_USER, 'Environment', 'PATH');
    setRegistryString(HKEY_CURRENT_USER, 'Environment', 'PATH_A',
        paths.join(Env().delimiterForPATH));
  }

  static void replacePath(List<String> path)
  {

  }

  /// Sets a Windodws registry key value
  static void setRegistryString(
      int hkey, String subKey, String valueName, String value,
      {int accessRights = KEY_SET_VALUE}) {
    final valueNamePtr = TEXT(valueName);
    final valuePtr = TEXT(value);

    try {
      withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
        final result = RegSetValueEx(
            hkey,
            valueNamePtr,
            0,
            REG_EXPAND_SZ,
            valuePtr.cast(),
            // utf16 is 2 bytes per char so value.length * 2
            value.length * 2 + 1);

        // ignore: invariant_booleans
        if (result != ERROR_SUCCESS) {
          throw WindowsException(HRESULT_FROM_WIN32(result));
        }
      });
    } finally {
      calloc..free(valueNamePtr)..free(valuePtr);
    }
  }

/// Sets a Windodws registry key value
  static void setRegistryList(
      int hkey, String subKey, String valueName, List<String> value,
      {int accessRights = KEY_SET_VALUE}) {
    final valueNamePtr = TEXT(valueName);
    
    final valuePtr = TEXT(value);

    try {
      withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
        final result = RegSetValueEx(
            hkey,
            valueNamePtr,
            0,
            REG_EXPAND_SZ,
            valuePtr.cast(),
            // utf16 is 2 bytes per char so value.length * 2
            value.length * 2 + 1);

        // ignore: invariant_booleans
        if (result != ERROR_SUCCESS) {
          throw WindowsException(HRESULT_FROM_WIN32(result));
        }
      });
    } finally {
      calloc..free(valueNamePtr)..free(valuePtr);
    }
  }

  /// Gets a Windows registry value.
  /// [hkey] is typically HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE
  ///
  /// See the following link for additional values:
  /// https://docs.microsoft.com/en-us/windows/win32/sysinfo/predefined-keys
  ///
  /// [subKey] is name of the registry key you want to open.
  /// This is typically something like 'Environment'.
  ///
  /// [accessRights] defines what rights are requried for the opened key.
  /// This is typically one of KEY_ALL_ACCESS, KEY_QUERY_VALUE,
  /// KEY_READ, KEY_SET_VALUE
  /// Refer to the following link for a full set of options.
  /// https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-key-security-and-access-rights
  ///
  /// throws [WindowsException] if the get failes
  static String getRegistryString(int hkey, String subKey, String valueName,
      {int maxLength = 1024, int accessRights = KEY_QUERY_VALUE}) {
    late final String value;
    final valueNamePtr = TEXT(valueName);
    final valuePtr = calloc<Utf16>(maxLength + 1);
    final dataSizePtr = calloc<Uint32>()..value = maxLength + 1;

    try {
      withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
        final result = RegGetValue(hkey, pSubKey, valueNamePtr, REG_EXPAND_SZ,
            nullptr, valuePtr.cast(), dataSizePtr);
        if (result != ERROR_SUCCESS) {
          throw WindowsException(HRESULT_FROM_WIN32(result));
        }
        value = valuePtr.toDartString();
      });
    } finally {
      calloc..free(valueNamePtr)..free(valuePtr)..free(dataSizePtr);
    }
    return value;
  }

  static List<String> getRegistryList(int hkey, String subKey, String valueName,
      {int accessRights = KEY_QUERY_VALUE}) {
    late final List<String> value;
    final valueNamePtr = TEXT(valueName);
    final dataSizePtr = calloc<Uint32>();

    try {
      withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
        /// get the buffer size
        final result = RegGetValue(hkey, pSubKey, valueNamePtr, REG_MULTI_SZ,
            nullptr, nullptr, dataSizePtr);

        if (result != ERROR_SUCCESS) {
          throw WindowsException(HRESULT_FROM_WIN32(result));
        }
        final valuePtr = calloc<Utf16>(dataSizePtr.value);
        try {
          final result = RegGetValue(hkey, pSubKey, valueNamePtr, REG_MULTI_SZ,
              nullptr, valuePtr.cast(), dataSizePtr);
          if (result != ERROR_SUCCESS) {
            throw WindowsException(HRESULT_FROM_WIN32(result));
          }
          value = valuePtr.unpackStringArray(dataSizePtr.value);
        } finally {
          calloc.free(valuePtr);
        }
      });
    } finally {
      calloc..free(valueNamePtr)..free(dataSizePtr);
    }
    return value;
  }
}

/// [hkey] is typically HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE
///
/// See the following link for additional values:
/// https://docs.microsoft.com/en-us/windows/win32/sysinfo/predefined-keys
///
/// [subKey] is name of the registry key you want to open.
/// This is typically something like 'Environment'.
///
/// [accessRights] defines what rights are requried for the opened key.
/// This is typically one of KEY_ALL_ACCESS, KEY_QUERY_VALUE,
/// KEY_READ, KEY_SET_VALUE
/// Refer to the following link for a full set of options.
/// https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-key-security-and-access-rights
///
R withRegKey<R>(int hkey, String subKey, int accessRights,
    R Function(int hkey, Pointer<Utf16> pSubKey) action) {
  R actionResult;
  final pOpenKey = calloc<IntPtr>();
  final pSubKey = TEXT(subKey);

  try {
    final result = RegOpenKeyEx(hkey, pSubKey, 0, accessRights, pOpenKey);
    if (result == ERROR_SUCCESS) {
      try {
        actionResult = action(pOpenKey.value, pSubKey);
      } finally {
        RegCloseKey(pOpenKey.value);
      }
    } else {
      throw WindowsException(HRESULT_FROM_WIN32(result));
    }
  } finally {
    calloc..free(pOpenKey)..free(pSubKey);
  }
  return actionResult;
}
