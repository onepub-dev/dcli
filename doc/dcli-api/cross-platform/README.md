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

The [https://pub.dev/packages/path](https://pub.dev/packages/path) package has a collection of functions for manipulating paths that will handle just about every circumstance you need.

## Escaping

DCli is designed to allow the easy development of cross platform scripts that run on Windows, Linux and MacOS.

This presents some problems when building paths and launching child processes.

On Windows the path separator is '\\' whilst on Linux and MacOS it is '/'.

Historically most systems us the '\\' character as the escape character. This proves problematic when you want to create path on Windows as each path separator would need to be double encoded as '\\\\'.

{% hint style="info" %}
You still use the standard \ character when creating Dart strings.  The escaping discussion only applies to how DCli parses command line arguments based to functions such as `start` AFTER the normal Dart string escaping has been applied..
{% endhint %}

Example:

```
'git commit \\aswitch foo^ bar'.run;
```

The above string will go through two transformations:

1\) Dart will see the `\\` and output a single `\`&#x20;

2\) the DCli run command will be given the output of step 1 and when parsing the command line output `foo bar` as a single argument.

DCli recommends using the `join` command (and associated functions) to build paths. If the '\\' was used as the escape character then every call to join would have to be wrapped in a function to escape the resulting path.

Additionally Dart uses the '\\' character as an escape character this can make building strings even harder as you need to double escape each backslash (of course you should be using the join command and not entering the path separator manually!).

To avoid these problem DCli uses the ^ character to escape command line arguments.

It should be noted that this ONLY affects the DCli commands that take a command line argument such as `start`, `run`, `forEach`, `toList` etc.

```dart
'git commit --message=foo^ bar'.run;
```

In this example we are escaping the space before the word bar.

The command will be parsed into the following arguments:

```dart
['git', 'commit', '--message=foo bar']
```

So the key advantage of using `^` is that when constructing paths with tools like `join` you don't need to do any escaping.

```dart
'git ${join(rootPath, 'git', 'myapp')}'.run;
```

The above command works on Windows and posix systems without requiring any escaping.





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

On Linux/Mac OS you can simply run the script (assuming it has a shebang at the top of the script).

```
'hello.dart'.run;
```

On Windows this method won't work as the Dart file association on Windows will only work if you spawn the command via a shell. The problem with spawning the command from a shell is that Windows doesn't appear to return the return value from the spawned script.

The best way to overcome this situation is create an instance of DartScript and run the script using its run method. This technique is guaranteed to be cross platform.

```dart
DartScript.fromFile('hello.dart'.run();
```

## Environment Variables

Environment variables between Windows and posix systems differ significantly.

DCli attempts to abstract some of these differences away.

### HOME

The 'HOME" environment variable works as expected on all platforms.

### PATH

The PATH environment variables at times need special handling on Windows.

The dcli PATH global getter returns a String list of paths, so for simple operations use this function.

For both Windows and posix systems you can't update the path of the parent process. This means that if you are running a DCli script from with in a shell (bash, command, zsh etc) that you cannot change the path of the that shell. This is a sensible security constraint imposed by all operating systems.

You can however modify the PATH for any child process you launch from your DCli script. To modify the PATH of a child process use one of the DCli Env() methods. This rule also applies for any environment variable. If you change any environment variable with DCli then any child process launched (after that point in time) will also see the updated environment variable.

You can change PATH environment in a persistent and DCli provides a number of helper methods.

Using Shell you can update the PATH environment variable in a persistent manner:

```dart
Shell.current.appendToPATH("/usr/me");
Shell.current.prependToPATH('C:\Users\Me\someapp');
```

NOTE: at this point in time not all implementations of Shell in DCli support these operations and they will return false if the operations isn't supported.

Currently the following Shell are supported:

* bash on linux
* Mac OS (append only)
* Windows - Power and Command shells

#### Windows

When updating the Windows PATH DCli will also send a notification to all top level applications that the PATH has been updated. You will however have to restart your Command or Powershell terminal as neither of these shells respond to the notification.

If you need more fine grained control DCli also provides a number of registry functions to directly modify the registry. There are a number of functions like \`regAppendToPath\` to assist. If you use one of the registry functions that include Path in the name then they will also send a Windows notification to all top level applications. Many application will respond to this notification and update their path. Unfortunately neither Command.exe nor Powershell respond to the notification so in both cases you will need to restart the terminal.

#### Mac OS

Only appending a path to the PATH is supported.

#### Linux

Bash is the only Shell with full support for the Shell path methods.

On Linux and Mac OS things are trickier as each shell has its own method of management the PATH environment.

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

In the above example '\*.txt' is a glob (a file pattern). On Linux and MacOS the expectation is that DCli will match the '\*.txt' expanding it into a list of files. The `ls` command is then called with that list of files as command line arguments.

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

On a Linux system a executable normally doesn't have a file extension. On Windows the file extension is .exe.

Further confusion is caused on Windows as when you enter a command such as 'regedit' on a terminal then Windows will search for regedit with a range of extensions such as .exe., .com, .bat, .msi ...

Windows takes the list of extension from the PATHEX environment variable.

To assist with finding the correct extension the DCli `which` function will search for a matching application with each of the extensions in PATHEX.

```dart
which('pub');
> linux -> pub
> windows -> pub.bat
```

This is intended to make it easier to run a command that may have different extensions on different OSs.

You can disable this search behaviour by setting extensionSearch to false:

```dart
which('pub', extensionSearch: false);
```

You can also have Windows apply the the extension search by using the 'runInShell' option on the start command.

```dart
start('pub', runInShell: true);
```
