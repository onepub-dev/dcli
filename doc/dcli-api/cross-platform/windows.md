# Windows

DCli ships with a number of Windows specific functions and classes.

Under the hood DCli uses the [win32](https://pub.dev/packages/win32) package which we recommend if you need additional Windows specific functionality.

The DCli Windows methods also rely heavily on the win32 package's constants such as `HKEY_CURRENT_USER` so in most circumstances you will need to import win32.

To add win32 to you dependencies.

```
pub add win32
```

To access the Windows specific APIs you need to import the windows barrel file.

```dart
import 'package:dcli/windows.dart';
import 'package:win32/win32.dart';
```

## Windows Registry

The Windows Registry is unique to Windows so if you want to write cross platform scripts then you should avoid using the Registry. However in some circumstances this simply isn't possible

In this case use the `Platform.isWindows` method to determine when to use the registry.

```dart
import 'dart:io';
import 'package:dcli/dcli.dart;

void main() {
    if (Plaform.isWindows) {
         regSetString(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST', 'HI');
    }
    else {
    /// do some posix stuff.
    }
}
```

## Windows specific functions

DCli includes:

### regAppendToPath

Appends \[newPath] to the Windows PATH environment variable.

### regIsOnUserPath

Returns true if the given \[path] is on the user's path.

### regPrependToPath

Prepend \[newPath] to the Windows PATH environment variable.

### regGetUserPath

Gets the User's Path (as opposed to the system path) as a list.

### regSetString

Sets a Windows registry key to a string value of type REG\_SZ.

### regSetNone

Sets a Windows registry valueName with a type REG\_NONE.

### regGetString

Gets a Windows registry value o0f type REG\_SZ \[hkey] is typically HKEY\_CURRENT\_USER or HKEY\_LOCAL\_MACHINE.

### regSetDWORD

Sets a Windows registry key to a string value of type REG\_SZ.

### regGetDWORD

Reads a DWORD from the registry.

### regDeleteKey

Deletes an registry key.

### regDeleteValue

Deletes an registry key.

### regGetExpandString

Retrieves a registry value located at \[hkey]/\[subKey]/\[valueName] that is of type REG\_EXPAND\_SZ.

### regSetExpandString

Sets the \[value] of the \[hkey] located at \[hkey]/\[subKey] in the Windows Registry. The \[value] is set to type REG\_EXPAND\_SZ.

### regKeyExists

Tests if a registry key exists.

### regCreateKey

Creates a registry key.



