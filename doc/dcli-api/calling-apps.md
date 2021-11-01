# Calling apps

## Calling other applications

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

The DCli API can run any console (CLI) application.

DCli provides a extensive number of methods to run CLI applications.

DCLI is also being able to process the output of any application it runs.

The importance of this ability is clearly reflected in the no. of ways that the DCli API gives you to run other apps.

### nothrow

DCli has a philosophy of explicit directives. By this we mean; if something doesn't work as explicitly stated then we throw an exception.

For example if you try to delete an directory that doesn't exist then DCli will throw an exception.

```dart
delete('non existant file');
```

When running CLI apps the convention is that an app returns '0' to indicate success.

You can do this in your own DCli scripts via a call to exit

```dart
import 'dart:io';
void main()
{
    exit(0);
}
```

One of the key consequences of this principle is that if you run an app from DCli and that application returns an non-zero exit code then DCli will throw an exception.

In most cases this is the correct action to take.

However some application return a non-zero exit code to indicate something other than a failure. In these cases you need to suppress the exception. A number of methods include a 'nothrow' option will will suppress the normal exception in the case of a non-zero exit code.

Using the 'nothrow' option allows you to obtain the exit code as well as any output from the application.

You also need to use the 'nothrow' option if you need to process any output that went to stderr when a non-zero exit code is returned.

### Treating Strings as commands

DCli extends the String class to provide a simple mechanism for running other CLI applications.

The aim of this somewhat unorthodox approach is to deliver the elegance that Bash achieves when calling CLI applications.

The following example shows how we have added a `run` method to the String class. The `run` method treats the String as a command line that is to be executed.

In this example we run the command 'wc' (word count) on the file 'fred.txt'. The output from the call to 'wc' will be displayed on the console.

```dart
 'wc fred.text'.run;
```

DCli adds a number of methods and operator overloads to the String class.

These include:

* run
* start
* forEach
* toList
* toParagraph
* firstLine
* lastLine
* \| operator

This is the resulting syntax:

```dart
    // run wc (word count) on a file
    // all wc output goes directly to the console
    'wc fred.text'.run;

     // Run echo as a detached process
    'echo into the void'.start(detached: true);

    // run grep, printing out each line but suppressing stderr
    'grep import *.dart'.forEach((line) => print(line)) ;

    // run tail printing out stdout and stderr
    'tail fred.txt'.forEach((line) => print(line)
        , stderr: (line) => print(line)) ;
    
    // run the 'ls' command in the /tmp directory
    'ls'.start(workingDirectory: '/tmp');
```

If you need to pass an argument to your application that contains spaces then use quotes: e.g.

```dart
   'wc "fred nurk.text"'.run
```

Dcli will strip the quotes and pass 'fred nurk.text' as a single argument.

### run

The run command is the simplest option for running an external application.

In runs the application, outputs both stderr and stdout to the console and waits for the application to complete.

```dart
'wc "fred nurk.text"'.run
```

### toList

This is probably one of the most common methods used as it captures any output from the called application and returns it as a list.

```dart
var results = 'wc "fred nurk.text"'.toList(skipLines: 1)
```

### start

Use the start function when you need more control over how the application executes.

#### workingDirectory

One of the most commonly use options is the 'workingDirectory'.

```dart
var results = 'wc "fred nurk.text"'.start(workingDirectory: '/home/me');
```

If you have read the section on the evils of CD then you will understand the need for the 'workingDirectory'. When you pass a workingDirectory to the 'start' command it executes the command ('wc') in the given workingDirectory rather than the user's present working directory (pwd).

#### privileged

If you need to run a command with escalated privileged then set the \[privileged] argument to true.

On Linux this equates to using the sudo command. The advantage of using the 'privileged' option it is cross platform and it will first check if you are already running in a privileged environment.

This is extremely useful if you are running in the likes of a Docker container that doesn't implement sudo but in which you are already running as root.

On Windows setting the priviliged argument to true will cause an exception to be thrown unless you are running as an Administrator.

Calling the 'isPrivileged' function returns true if you are running under sudo/root on posix systems and true if you are running as an Administrator on Windows.

### which

While the 'which' function doesn't run an executable it can be invaluable as it searches your PATH for the location of an executable.

To run an executable with any of the DCli methods you DON'T need to know its location (provided it's on the path) but sometimes you want to know if an executable is installed before you try to run it.

```dart
if (which('grep').found) print('grep is installed');
if (which('grep').notfound) print('grep is not installed');
```

To get the path to the 'grep' command:

```dart
var grepPath = which('grep').path;
```

The 'which' function may find multiple copies of grep on your path in which case it will return each of them in an array in the order that they were found on the path.

In the above example we use the 'path' function to return the first path found for the 'grep' command.

To see all the locations of grep use:

```dart
List<String> where = which('grep').paths
```

You can also use the 'which' function to determine if a particular program is installed:

```dart
if (which('grep').isEmpty) print('grep not installed');
```

Of course in reality we are just seeing if grep is on the path. In theory it could be installed by not on the path.

**Cross Platform which**

The `which` offers built in cross platform support.

On posix systems (Linux, Mac OS) executables normally do not have a file extension. On Windows executables will have a file extension such as '.exe'.

So on posix we have`grep` whilst on Windows we have `grep.exe`.

Windows provides the list of executable extensions in the PATHEXT environment variable.

The `which` funciton uses PATHEXT when searching for matching commands. So if you call:

```dart
which('grep')
```

On a Posix systems we might see:

```dart
which('grep').path == '/usr/bin/grep';
```

On Windows we might see one of:

```dart
which('grep').path == 'C:\Windows\grep.exe';
which('grep').path == 'C:\Windows\grep.bat';
```

If you pass an extension to the which command then DCli will not search for alternate extensions:

```dart
which('grep.exe').path == 'C:\Windows\grep.exe';
```

You can stop which searching for alternate extension by passing `extensionsSearch: false`

```dart
which('grep', extensionSearch: false).notfound == true
```

## Escaping

Prior to DCli 1.10, DCli did not support escaping of command arguments.

DCli provides a number of methods to call an external process. Commands such as `start` and `run` allow you to pass a full command line.

One common problem when passing a full command line is escaping.

Traditionally the backslash character '\\' has been used to escape special characters however DCli aims to be cross platform and this causes problems when running under Windows as the backslash '\\' character is used as a path separator.

Dart also use the the backslash '\\' character to escape which further confuses issues.

To avoid these issues DCli uses the '^' character for command line escaping.

As with all escaping schemes to insert a '^' escape it with a double hat '^^'.

In bash you might write something like:

```bash
cat hello\ world.txt
```

To run the above command using DCli you would write

```dart
'cat hello^ world.txt'.run;
```

Of course a better alternative is to avoid escaping whenever possible. The above command could be written as:

```dart
'cat "hello world.txt"'.run
```

The intent of this command is (imho)  much clearer.



