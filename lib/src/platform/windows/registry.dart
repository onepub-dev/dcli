import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../../functions/env.dart';

/// Collection of Windows specific registry functions.

// TODO(bsutton): impement notification so desktop apps
// update their environment.
/// Appends [newPath] to the Windows `PATH environment variable.
void appendToPath(String newPath) {
  // const char * what = "Environment";
  // DWORD rv;
  // SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
  // 						(LPARAM) what, SMTO_ABORTIFHUNG, 5000, & rv );

  final paths = getRegistryExpandString(
          HKEY_CURRENT_USER, 'Environment', 'Path',
          expand: false)
      .split(Env().delimiterForPATH)
        ..add(newPath);

  setRegistryExpandString(HKEY_CURRENT_USER, 'Environment', 'Path',
      paths.join(Env().delimiterForPATH));
}

/// Gets the User's Path (as opposed to the system path)
/// as a list.
/// If [expand] is set to true (the default) then any embedded
/// enironment variables are expanded out.
List<String> getUserPath({bool expand = true}) =>
    getRegistryExpandString(HKEY_CURRENT_USER, 'Environment', 'Path',
            expand: expand)
        .split(';');

// // TODO(bsutton): impement notification so desktop apps
// // update their environment.
// /// Replaced the existing Windows PATH with [newPath].
// ///
// /// WARNING: becareful using this method. If you get it wrong
// /// you can destroy your Windows PATH which will stop lots
// ///  of things (everything?) from working.
// void replacePath(List<String> newPaths) {
//   // const char * what = "Environment";
//   // DWORD rv;
//   // SendMessageTimeout( HWND_BROADCAST, WM_SETTINGCHANGE, 0,
//   // 						(LPARAM) what, SMTO_ABORTIFHUNG, 5000, & rv );

//   setRegistryExpandString(HKEY_CURRENT_USER, 'Environment', 'Path',
//       newPaths.join(Env().delimiterForPATH));
// }

/// Sets a Windows registry key to a string value of type REG_SZ
void setRegistryString(int hkey, String subKey, String name, String value,
    {int accessRights = KEY_SET_VALUE}) {
  final pValue = TEXT(value);

  try {
    _setRegistryValue(
        hkey, subKey, name, pValue.cast(), (value.length + 1) * 2, REG_SZ);
  } finally {
    calloc.free(pValue);
  }
}

/// Gets a Windows registry value o0f type REG_SZ
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
String getRegistryString(int hkey, String subKey, String name,
    {int accessRights = KEY_QUERY_VALUE}) {
  late final String value;

  final pResult = _regGetValue(hkey, subKey, name, accessRights: accessRights);
  try {
    value = pResult.toDartString();
  } finally {
    pResult.free();
  }
  return value;
}

/// Retrieves a registry value located at [hkey]/[subKey]/[name]
/// that is of type REG_EXPAND_SZ.
/// If [expand] is true then any environment variables in the value
/// are expanded. If [expand] is false then the value is returned un-expanded.
String getRegistryExpandString(int hkey, String subKey, String name,
    {int accessRights = KEY_QUERY_VALUE, bool expand = true}) {
  late final String value;

  var flags = RRF_RT_REG_SZ;

  if (expand == false) {
    // flags = RRF_NOEXPAND;
    flags = RRF_RT_REG_EXPAND_SZ | RRF_NOEXPAND;
  }

  final pResult = _regGetValue(hkey, subKey, name,
      flags: flags, accessRights: accessRights);
  try {
    value = pResult.toDartString();
  } finally {
    pResult.free();
  }
  return value;
}

/// Sets the [value] of the [key] located at [hkey]/[subKey] in the Windows
/// Registry. The [value] is set to type REG_EXPAND_SZ
void setRegistryExpandString(int hkey, String subKey, String name, String value,
    {int accessRights = KEY_SET_VALUE}) {
  final pValue = TEXT(value);
  try {
    _setRegistryValue(hkey, subKey, name, pValue.cast(), (value.length + 1) * 2,
        REG_EXPAND_SZ);
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
}

/// You must free the returned value using calloc.free
_RegResults _regGetValue(int hkey, String subKey, String name,
    {int flags = RRF_RT_REG_SZ, int accessRights = KEY_QUERY_VALUE}) {
  late final Pointer<Uint8> pResult;
  final pName = TEXT(name);
  // and somewhere to store the size of the result.
  final pResultSize = calloc<Uint32>();

  late final int type;
  final pType = calloc<Uint32>();

  try {
    withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
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
    calloc..free(pName)..free(pResultSize)..free(pType);
  }
  // ignore: avoid_dynamic_calls
  return _RegResults(pResult, pResultSize.value, type);
}

/// Sets a Windows registry key to the value pointed to by [pValue]
/// which is of [valueSize] and type [type].
/// [type] must be one of the standard registry types such as REG_SZ.
/// [valueSize] is the size of pValue in bytes.
void _setRegistryValue(int hkey, String subKey, String name,
    Pointer<Uint8> pValue, int valueSize, int type,
    {int accessRights = KEY_SET_VALUE}) {
  final pName = TEXT(name);

  try {
    withRegKey(hkey, subKey, accessRights, (hkey, pSubKey) {
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

/// Packs a List of Dart Strings into a native memory block.
/// Each String is terminated by a null with a
/// double null to represent the end of the list.
/// The resulting format is that required to write a list of values
/// to the registry.
///
/// It is the responsibility of the caller to [free] the returned
/// pointer.
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
