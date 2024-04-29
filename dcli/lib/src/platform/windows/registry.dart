/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:win32/win32.dart';

import '../../../dcli.dart';
import 'message.dart';

/// The system cannot find the file specified.
const hrFileNotFound = -2147024894;

/// Use this key when adding a value to a default (Default) registry
/// key.
const defaultRegistryValueName = '';

/// Collection of Windows specific registry functions.

/// Appends [newPath] to the Windows PATH environment variable.
///
/// A [WindowsException] is thrown if the call falls.
void regAppendToPath(String newPath) {
  final paths = _getPaths();
  if (!_isOnUserPath(newPath, paths)) {
    paths.add(newPath);
    _replacePath(paths);
  }
}

/// Returns true if the given [path] is on the user's
/// path.
///
/// Note: this does not check the system path.
bool regIsOnUserPath(String path) {
  final paths = _getPaths();
  return _isOnUserPath(path, paths);
}

bool _isOnUserPath(String path, List<String> userPaths) {
  final canonicalPath = canonicalize(path);
  return userPaths.map(canonicalize).contains(canonicalPath);
}

/// Prepend [newPath] to the Windows PATH environment variable.
///
/// A [WindowsException] is thrown if the call falls.
void regPrependToPath(String newPath) {
  final paths = _getPaths();

  if (!_isOnUserPath(newPath, paths)) {
    paths.insert(0, newPath);
    _replacePath(paths);
  }
}

List<String> _getPaths() {
  final paths = regGetExpandString(
    HKEY_CURRENT_USER,
    'Environment',
    'Path',
    expand: false,
  ).split(Env().delimiterForPATH);
  return paths;
}

void _replacePath(List<String> paths) {
  regSetExpandString(
    HKEY_CURRENT_USER,
    'Environment',
    'Path',
    paths.join(Env().delimiterForPATH),
  );

  broadcastEnvironmentChange();
}

/// Gets the User's Path (as opposed to the system path)
/// as a list.
///
/// If [expand] is set to true (the default) then any embedded
/// enironment variables are expanded out.
/// A [WindowsException] is thrown the call falls.
List<String> regGetUserPath({bool expand = true}) =>
    regGetExpandString(HKEY_CURRENT_USER, 'Environment', 'Path', expand: expand)
        .split(';');

// TODO(bsutton): impement notification so desktop apps
// update their environment.
/// Replaced the existing Windows PATH with [newPaths].
///
/// WARNING: becareful using this method. If you get it wrong
/// you can destroy your Windows PATH which will stop lots
///  of things (everything?) from working.
/// A [WindowsException] is thrown the call falls.
void regReplacePath(List<String> newPaths) {
  // const char * what = "Environment";
  // DWORD rv;
  // SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
  // 						(LPARAM) what, SMTO_ABORTIFHUNG, 5000, & rv );

  regSetExpandString(
    HKEY_CURRENT_USER,
    'Environment',
    'Path',
    newPaths.join(Env().delimiterForPATH),
  );

  broadcastEnvironmentChange();
}

/// Sets a Windows registry key to a string value of type REG_SZ.
///
/// A [WindowsException] is thrown the call falls.
void regSetString(
  int hkey,
  String subKey,
  String valueName,
  String value, {
  int accessRights = KEY_SET_VALUE,
}) {
  final pValue = TEXT(value);

  try {
    _regSetValue(
        hkey, subKey, valueName, pValue.cast(), (value.length + 1) * 2, REG_SZ,
        accessRights: accessRights);
  } finally {
    calloc.free(pValue);
  }
}

/// Sets a Windows registry valueName with a type REG_NONE.
///
/// No value is set.
/// A [WindowsException] is thrown the call falls.
void regSetNone(
  int hkey,
  String subKey,
  String valueName, {
  int accessRights = KEY_SET_VALUE,
}) {
  _regSetValue(hkey, subKey, valueName, nullptr, 0, REG_NONE,
      accessRights: accessRights);
}

/// Gets a Windows registry value o0f type REG_SZ
/// [hkey] is typically HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE.
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
String regGetString(
  int hkey,
  String subKey,
  String valueName, {
  int accessRights = KEY_QUERY_VALUE,
}) {
  late final String value;

  final pResult =
      _regGetValue(hkey, subKey, valueName, accessRights: accessRights);
  try {
    value = pResult.toDartString();
  } finally {
    pResult.free();
  }
  return value;
}

/// Sets a Windows registry key to a string value of type REG_SZ.
///
/// A [WindowsException] is thrown the call falls.
void regSetDWORD(
  int hkey,
  String subKey,
  String valueName,
  int value, {
  int accessRights = KEY_SET_VALUE,
}) {
  final pValue = calloc<Uint32>()..value = value;

  try {
    _regSetValue(
        hkey, subKey, valueName, pValue.cast(), sizeOf<Uint32>(), REG_DWORD,
        accessRights: accessRights);
  } finally {
    calloc.free(pValue);
  }
}

/// Reads a DWORD from the registry.
///
/// A [WindowsException] is thrown the call falls.
int regGetDWORD(
  int hkey,
  String subKey,
  String valueName, {
  int accessRights = KEY_QUERY_VALUE,
}) {
  late final int value;

  final pResult = _regGetValue(
    hkey,
    subKey,
    valueName,
    accessRights: accessRights,
    flags: RRF_RT_DWORD,
  );
  try {
    value = pResult.toDWORD();
  } finally {
    pResult.free();
  }
  return value;
}

/// Deletes an registry key.
///
/// [subKey] maybe be a path such as Microsoft/Windows
/// A [WindowsException] is thrown if the delete fails.
void regDeleteKey(
  int hkey,
  String subKey,
) {
  final pSubKey = TEXT(subKey);

  try {
    final result = RegDeleteKeyEx(hkey, pSubKey, KEY_WOW64_64KEY, 0);
    if (result != ERROR_SUCCESS) {
      throw WindowsException(HRESULT_FROM_WIN32(result));
    }
  } finally {
    calloc.free(pSubKey);
  }
}

/// Deletes an registry key.
///
/// [subKey] maybe be a path such as Microsoft/Windows
/// [valueName] is the name of the value stored under [subKey]
/// A [WindowsException] is thrown if the delete fails.
void regDeleteValue(
  int hkey,
  String subKey,
  String valueName,
) {
  final pName = TEXT(valueName);
  try {
    _withRegKey(hkey, subKey, KEY_WRITE, (hkey, pSubKey) {
      // var sub = TEXT(path)
      final result = RegDeleteValue(hkey, pName);
      if (result != ERROR_SUCCESS) {
        throw WindowsException(HRESULT_FROM_WIN32(result));
      }
    });
  } finally {
    calloc.free(pName);
  }
}

/// Retrieves a registry value located at [hkey]/[subKey]/[valueName]
/// that is of type REG_EXPAND_SZ.
///
/// If [expand] is true then any environment variables in the value
/// are expanded. If [expand] is false then the value is returned un-expanded.
/// A [WindowsException] is thrown the call falls.
String regGetExpandString(
  int hkey,
  String subKey,
  String valueName, {
  int accessRights = KEY_QUERY_VALUE,
  bool expand = true,
}) {
  late final String value;

  var flags = RRF_RT_REG_EXPAND_SZ | RRF_RT_REG_SZ;

  if (expand == false) {
    flags |= RRF_NOEXPAND;
  }

  final pResult = _regGetValue(
    hkey,
    subKey,
    valueName,
    flags: flags,
    accessRights: accessRights,
  );
  try {
    value = pResult.toDartString();
  } finally {
    pResult.free();
  }
  return value;
}

/// Sets the [value] of the [hkey] located at [hkey]/[subKey] in the Windows
/// Registry. The [value] is set to type REG_EXPAND_SZ.
///
/// A [WindowsException] is thrown the call falls.
void regSetExpandString(
  int hkey,
  String subKey,
  String valueName,
  String value, {
  int accessRights = KEY_SET_VALUE,
}) {
  final pValue = TEXT(value);
  try {
    _regSetValue(hkey, subKey, valueName, pValue.cast(), (value.length + 1) * 2,
        REG_EXPAND_SZ,
        accessRights: accessRights);
  } finally {
    calloc.free(pValue);
  }
}

// /// Sets a Windodws registry key value
// void setRegistryList(
//     int hkey, String subKey, String valueName, List<String> value,
//     {int accessRights = KEY_SET_VALUE}) {
//   final valueNamePtr = TEXT(valueName);

//   final valuePtr = _packStringArray(value);
//   final packedSize = value.fold<int>(
//           0, (previousValue, element) => previousValue + element.length) +
//       1;

//   try {
//     withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
//       final result = RegSetValueEx(
//           hkey, valueNamePtr, 0, REG_MULTI_SZ, valuePtr.cast(), packedSize);

//       // ignore: invariant_booleans
//       if (result != ERROR_SUCCESS) {
//         throw WindowsException(HRESULT_FROM_WIN32(result));
//       }
//     });
//   } finally {
//     calloc..free(valueNamePtr)..free(valuePtr);
//   }
// }

// List<String> getRegistryList(int hkey, String subKey, String name,
//     {int accessRights = KEY_QUERY_VALUE}) {
//   late final List<String> value;

//   final pResult = _regGetValue(hkey, subKey, name,
//       flags: RRF_RT_REG_MULTI_SZ, accessRights: accessRights);
//   try {
//     value = pResult.unpackStringArray();
//   } finally {
//     pResult.free();
//   }
//   return value;
// }

class _RegResults {
  _RegResults(this.pResult, this.size, this.type);
  Pointer<Uint8> pResult;
  int size;

  /// The type of data returned.
  /// e.g. REG_SZ
  int type;

  void free() => calloc.free(pResult);

  List<String> unpackStringArray() =>
      pResult.cast<Utf16>().unpackStringArray(size);

  String toDartString() => pResult.cast<Utf16>().toDartString();

  int toDWORD() => pResult.cast<Uint32>().value;
}

/// You must free the returned value using calloc.free
///
/// A [WindowsException] is thrown the call falls.
_RegResults _regGetValue(
  int hkey,
  String subKey,
  String valueName, {
  int flags = RRF_RT_REG_SZ,
  int accessRights = KEY_QUERY_VALUE,
}) {
  late final Pointer<Uint8> pResult;
  final pName = TEXT(valueName);
  // and somewhere to store the size of the result.
  final pResultSize = calloc<Uint32>();

  late final int type;
  final pType = calloc<Uint32>();

  try {
    _withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
      // get the buffer size required.
      var result = RegGetValue(
        hkey,
        nullptr,
        pName,
        RRF_RT_ANY,
        pType,
        nullptr,
        pResultSize,
      );
      if (result != ERROR_SUCCESS) {
        throw WindowsException(HRESULT_FROM_WIN32(result));
      }
      type = pType.value;
      // allocate some space for the call to store the result into.
      pResult = calloc<Uint8>(pResultSize.value);
      result = RegGetValue(
        hkey,
        nullptr,
        pName,
        flags,
        nullptr,
        pResult,
        pResultSize,
      );
      if (result != ERROR_SUCCESS) {
        throw WindowsException(HRESULT_FROM_WIN32(result));
      }
    });
  } finally {
    calloc
      ..free(pName)
      ..free(pResultSize)
      ..free(pType);
  }
  // ignore: avoid_dynamic_calls
  return _RegResults(pResult, pResultSize.value, type);
}

/// Sets a Windows registry key to the value pointed to by [pValue]
/// which is of [valueSize] and type [type].
///
/// [type] must be one of the standard registry types
///   such as REG_SZ.
/// [valueSize] is the size of pValue in bytes.
/// A [WindowsException] is thrown the call falls.
void _regSetValue(
  int hkey,
  String subKey,
  String valueName,
  Pointer<Uint8> pValue,
  int valueSize,
  int type, {
  int accessRights = KEY_SET_VALUE,
}) {
  final pName = TEXT(valueName);

  try {
    _withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
      final result =
          RegSetValueEx(hkey, pName, 0, type, pValue.cast(), valueSize);
      // ignore: invariant_booleans
      if (result != ERROR_SUCCESS) {
        throw WindowsException(HRESULT_FROM_WIN32(result));
      }
    });
  } finally {
    calloc.free(pName);
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
/// A [WindowsException] is thrown the call falls.
R _withRegKey<R>(
  int hkey,
  String subKey,
  int accessRights,
  R Function(int hkey, Pointer<Utf16> pSubKey) action,
) {
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
    calloc
      ..free(pOpenKey)
      ..free(pSubKey);
  }
  return actionResult;
}

/// Tests if a registry key exists.
///
/// [hkey] is typically HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE
///
/// See the following link for additional values:
/// https://docs.microsoft.com/en-us/windows/win32/sysinfo/predefined-keys
///
/// [subKey] is name of the registry key you want to open.
/// This is typically something like 'Environment'.
///
/// A [WindowsException] is thrown the call falls.
bool regKeyExists(
  int hkey,
  String subKey,
) {
  var exists = false;
  final pOpenKey = calloc<IntPtr>();
  final pSubKey = TEXT(subKey);

  try {
    final result = RegOpenKeyEx(hkey, pSubKey, 0, KEY_QUERY_VALUE, pOpenKey);
    if (result == ERROR_SUCCESS) {
      exists = true;
      RegCloseKey(pOpenKey.value);
    }
  } finally {
    calloc
      ..free(pOpenKey)
      ..free(pSubKey);
  }
  return exists;
}

/// Creates a registry key.
///
/// Throws a [WindowsException] if the key cannot be created.
void regCreateKey(
  int hKey,
  String subKey,
) {
  final pOpenKey = calloc<IntPtr>();
  final pSubKey = TEXT(subKey);
  try {
    final result = RegCreateKeyEx(
        hKey,
        pSubKey,
        0,
        nullptr,
        0,
        KEY_QUERY_VALUE,
        nullptr, // not inheritable
        pOpenKey,
        nullptr);

    if (result != ERROR_SUCCESS) {
      throw WindowsException(HRESULT_FROM_WIN32(result));
    }
    RegCloseKey(pOpenKey.value);
  } finally {
    calloc
      ..free(pOpenKey)
      ..free(pSubKey);
  }
}

/// Packs a List of Dart Strings into a native memory block.
/// Each String is terminated by a null with a
/// double null to represent the end of the list.
/// The resulting format is that required to write a list of values
/// to the registry.
///
/// It is the responsibility of the caller to [free] the returned
/// pointer.
// ignore: unused_element
Pointer<Utf16> _packStringArray(List<String> values) {
  var size = 0;

  // calculate the total memory required to store
  // the list of strings into native memory.
  for (final value in values) {
    size += value.length + 1;
  }

  /// trailing null after last value
  size++;

  final pArray = calloc<Uint16>(size);
  final ptr = pArray.cast<Uint16>().asTypedList(size);

  var index = 0;
  for (final value in values) {
    final units = value.codeUnits;

    ptr.setAll(index, units);
    ptr[index + units.length] = 0;

    index += value.length + 1;
  }
  ptr[index] = 0;

  return pArray.cast();
}
