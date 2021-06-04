# Cross Platform

Dart and DCli are designed to be cross platform with support for Linux, Mac OS and Windows.

Most of the API's in DCli can be used without consideration for which platform you are running on. There are however a number of issues that you should be aware of.

## Platform

If you need to perform an OS specific operation the you can use the Dart `Platform` class:

```dart
import 'dart:io';
import 'package:dcli/dcli.dart;

void main() {
    if (Plaform.isWindows) {
         // do windows stuff
    }
    else if (Platform.isLinux) {
    /// do some linux stuff
    } else if (Platform.isMacOS)
    {
    // do mac stuff.
}
```

For the most part you will find little need to differentiate between Linux and Mac OS unless you are spawning an OS application.

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

On Windows if you want to build a path that operates on the current drive without including the drive in the path then use:

```dart
var path = join(separator, 'var', tmp);
```

This will result in:

Linux/MacOS: \`/var/tmp'

Windows: r'\var\tmp'.

Windows will interpret the above path to apply to whatever drive is current the active drive.

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

## Windows Registry

The Windows Registry is unique to Windows so if you want to write cross platform scripts then you should avoid using the Registry. However in some circumstances this simply isn't possible

In this case use the `Platform.isWindows` method to determine when to use the registery.

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

## Built in OS Applications

The set of application supplied by an OS varies considerably so you need to be careful when spawning an application.

Even between Linux distributions there can be differences in what applications are installed by default.

Before spawning an OS application you should check if it exists and whether it is on the PATH. The which function is the most convenient method to do this.

```dart
if (which('ls').found) {
    'ls *.txt'.run;
} else {
    find('*.txt').forEach((file) => print(file);
}
```

Depending on the complexity of the command it may be easier to simply implement it directly in Dart or find a Dart package on [https://pub.dev](https://pub.dev) that provides the required functionality.

## Glob expansion

When spawning a command DCli follows the rules of the OS on expanding globs.

```dart
'ls *.txt'.run;
```

In the above example '\*.txt' is a glob \(a file pattern\). On Linux and MacOS the expectation is that DCli will match the '\*.txt' expanding it into a list of files.  The `ls` command is then called with that list of files as command line arguments.

```dart
`ls *.txt'.run;

becomes

'ls fred.txt tom.txt'.run.
```

Windows however does not expect globs to be expanded as such we directly pass the glob to the called application.

If you are calling into a native Windows application then everything will work as expected. However if you have written a Dart script which you are now calling you need to understand that the arguments passed to the Dart script will change dependant on which platform the script is running on.

On Windows you will need to have your Dart script expand the glob.

There is a [glob](https://pub.dev/packages/glob) package on pub.dev that will help you to do this.

## Executable Names

Naming conventions for executables differ between Linux/Mac OS and Windows.

On a linux system a executable normally doesn't have a file extension.

