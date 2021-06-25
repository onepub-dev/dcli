# Calling apps

## Calling other applications

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

The DCli API can run any console \(CLI\) application.

DCli provides a extensive number of methods to run CLI applications.

DCLI is also  being able to process the output of any  application it runs.

The importance of this ability is clearly reflected in the no. of ways that the DCli API gives you to run other apps.

### nothrow

DCli has a philosophy of explicit directives. By this we mean;  if something doesn't work as explicitly stated then we throw an exception.

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

In this example we run the command 'wc' \(word count\) on the file 'fred.txt'. The output from the call to 'wc' will be displayed on the console.

```dart
 'wc fred.text'.run;
```

DCli adds a number of methods and operator overloads to the String class.

These include:

* run
* start
* forEach
* toList
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

If you have read the section on the evils of CD then you will understand the need for the 'workingDirectory'. When you pass a workingDirectory to the 'start' command it executes the command \('wc'\) in the given workingDirectory rather then the user's present working directory \(pwd\).

#### privileged

If you need to run a command with escalated privileged then set the \[privileged\] flag. argument to true.

On Linux this equates to using the sudo command. The advantage of using the 'privileged' option it is cross platform and it will first check if you are already running in a privileged environment.

This is extremely useful if you are running in the likes of a Docker container that doesn't implement sudo but in which you are already running as root.

### which

While the 'which' function doesn't run an executable it can be invaluable as it searches your PATH for the location of an executable.

To run an executable with any of the DCli methods you don't need to know its location \(provided its on the path\) but some times you want to know if an executable is installed before you try to run it.

```dart
var grepPath = which('grep').first;
```

The 'which' function may find multiple copies of grep on your path in which case it will return each of them in an array in the order that they were found on the path.

In the above example we use the 'first' function to return the first path found for the 'grep' command.

You can also use the 'which' function to determine if a particular progam is installed:

```dart
if (which('grep').isEmpty) print('grep not installed');
```

Of course in reality we are just seeing if grep is on the path. In theory it could be installed by not on the path.

