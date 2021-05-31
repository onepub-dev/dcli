# Cross Platform

Dart and DCli are designed to be cross platform with support for Linux, Mac OS and Windows.

Most of the API's in DCli can be used without consideration for which platform you are running on. There are however a number of issues that you should be aware of.

## Paths

One of the biggest headaches with building cross platform apps is the differences in paths.

Windows uses a drive designator C: and the backslash character \ whilst Linux and OSX use the forward slash /.

Most of the problems around Paths can be avoided by using the [https://pub.dev/packages/path](https://pub.dev/packages/path) package which is included in DCli.

So rather than hard coding a path like:

```dart
var path = '/var/tmp';
```

Use the paths package:

```dart
var path = join(rootPath, 'var', tmp);
```

On Windows `path` will be `C:\var\tmp` assuming that your current drive is the C: drive.

On Linux and Mac OS the `path` will be `/var/tmp`.

The [https://pub.dev/packages/path](https://pub.dev/packages/path)  package has a collection of functions for manipulating paths that will handle just about every circumstance you need.

## Launching Dart Scripts

On each Platform you can run a dart script directly from the command line.

On Linux/Mac OS

```bash
./hello.dart
```

On Windows

```bash
hello.dart
```

There is however an issue when trying to spawn a dart script from with a DCli script or other shell script.

On Linux/Mac OS you can simply run the script \(assuming it has a shebang at the top of the script\).

```text
'hello.dart'.run;
```

On Windows this method won't work as the Dart file association on Windows will only work if you spawn the command via a shell. The problem with spawning the command from a shell is that Windows doesn't appear to return the return value from the spawned script.

The best way to overcome this situation is to prefix the command with `dart` this will work on all of the supported OSs

```dart
'dart hello.dart'.run
```

