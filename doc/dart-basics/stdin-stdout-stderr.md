# stdin/stdout/stderr a primer

When building console apps you are going to hear a lot about three little entities: stdin, stdout and stderr.

In the Linux, Windows and OSX world any time you launch an application three file descriptors are automatically opened and attached to the application.

I refer to these three file descriptors as 'the holy trinity'. If you are going to do Command Line Interface (CLI) programming then it is imperative that you understand what they are and how to use them.

This primer discusses the origins, the structure and finally how to interact with the holy trinity in CLI apps.

{% hint style="info" %}
stdin/stdout/stderr are not unique to dart. Virtually every langue and OS supports them.
{% endhint %}

At the most basic level, each of these files is intended to have a specific purpose.

stdin -  lets you read input from a user

stdout -  lets you show information to the user

stderr - lets you show errors to the user.

As a visual aid, you can think of the files as:

```
[stdin -> app -> stdout
              -> stderr]
```

But these files are anything but basic and it's not just a user that we can communicate with.

## In the beginning

Let's take a little history lesson.

Way back in the dark ages (circa 1970) the computer gods got together and created Unix.

{% hint style="info" %}
And Dennis said, let there be 'C'. And Denis looked upon 'C' and said it was good and the people agreed.

But Dennis did not rest on the seventh day, instead, he called upon Kenneth and over lunch and a nice red, they doth created Unix.

Dennis Ritchie; 9th Sept 1944 - 12th Oct 2011\
Kenneth Lane Thompson February 4, 1943
{% endhint %}

![My first bible.](<../.gitbook/assets/image (1) (1) (1) (1) (1) (1) (1) (1) (1) (1) (1).png>)

Unix is the direct ancestor of Linux, MacOS and to a lesser extent Windows. You might more correctly say that 'C' is the common ancestor of all three OSs, as their kernels are all written in C.

As C was taken up as the primary language for writing Operating Systems, the concept of stdin/stdout and stderr proliferated across the OS world.

The result is today that a large no. of operating systems support stdin/stdout and stderr.

The majority of people reading this primer will be working with Linux, MacOS or Windows and in each of these cases, the Holy Trinity (stdin/stdout/stderr) is available in every app they use or write.

The following examples are presented using the Dart programming language, but the concepts and even most of the details are correct across multiple OSs and languages.

## When you have a hammer, everything's a snail

In the Unix world, EVERYTHING is a file. Even devices and processes are treated as files.

{% hint style="info" %}
If you know where to look, processes and devices are visible in the Linux/MacOS directory tree as files.
{% endhint %}

So if everything is a file, does that mean we can directly read/write to a device/process/directory?

The simple answer is, yes.

If we want to read/write to a file we need to open the file. In the Unix world (and virtually every other OS) when we open a file we get a 'file descriptor' or FD for short. Once we have an FD we can read and write to the file. The FD may be presented differently in your language of choice but under the hood, it's still an FD. (**In Dart we have the File class that wraps an FD**).

> The terms 'file descriptor' and 'file handle' are often used interchangeably.

So what exactly is an FD? Under the hood, an FD is just an integer that acts as an index to an array of open files. The FD array contains information such as the path to the file, the size of the file, the current seek position and more.

## The Holy Trinity

So now we understand that in Unix everything is a file, you probably won't be surprised when I tell you that stdin/stdout/stderr are also files.

So if stdin/stdout/stderr are files, how do you open them?

The answer is you don't need to open them, the OS opens them for you. When your app starts, it is passed one file descriptor (FD) for each of stdin/stdout/stderr.

If you recall, we said that an FD is just an integer, indexing into an array of structures, with one array entry for each open file. Each application has its own array. When your app starts that array already has three entries, stdin, stdout and stderr.

The order of those entries in the array is important.

\[0] = stdin

\[1] = stdout

\[2] = stderr.

If you open any additional files they will appear as element \[3] and greater.

## The tower of Babel

If you have done any Bash, Zsh, Command or Powershell programming you may have seen a line similar to:

```
find . '*.png' >out.txt 2>&1
```

You can't get much more obtuse than the above line, but now we know about FD's it actually makes a little more sense.

{% hint style="warning" %}
Bash was not created by the gods. I think the other bloke had a hand in this one.
{% endhint %}

The `>out.txt` section is actually a shorthand for `1>out.txt` . It instructs Bash to take anything that `find` writes to FD =1 (stdout) and re-write it to the file called 'out.txt'.

The `2> &1` section instructs Bash to take anything `find` writes to FD=2 (stderr) and re-write it to FD=1.&#x20;

i.e. anything written to stderr (FD=2) is re-written to stdout (FD=1) which in turn is written to `out.txt`.  &#x20;

The result of the above command is that both stdout and stderr are written to the file called 'out.txt'.

It would have been less obtuse to write:

```
find . '*.png' 1>out.txt 2>out.txt
```

But of course, we are talking about Bash here and apparently more obtuse is always better :D

> Many other shells use a similar syntax.

Most languages provide a specific wrapper for each f these file handles. In Dart we have the global properties:

* stdin
* stdout
* stderr

> The 'C' programming language has the same three properties and many other languages use the same names.

## And on this rock, I will build my app

I like to think of the Unix philosophy as programming by Lego (but Meccano is superior).

{% hint style="info" %}
Unix was all about Lego - build lots of little bricks (apps) that can be connected.
{% endhint %}

In the Unix world (and the Dart world) every CLI app you write contributes to the set of available Lego bricks. But Lego bricks would be useless unless you can connect them. In order to connect bricks the 'pegs' on each brick must match the 'holes' on other bricks and that's where stdin/stdout/stderr come in.

In the Unix world every brick (app) has three connection points:

* stdin - a hole for input
* stdout - a peg for normal output
* stderr - a peg for error output

Any peg can go into any hole.

You might now have guessed that you can connect stdout from one program to stdin on another program:

\[myapp -> stdout] => \[stdin -> yourapp]

If you are familiar with Bash you may have even seen one of the common ways to connect two apps.

```
ls "*.png" | grep "turtles"
```

In the above example, the `ls` command will write a list of files that end in `.png`. The grep command will receive that list and then output a line each time it sees a filename that contains the word `turtles`.

The Bash  '|' pipe operator connects the stdout of 'ls' to the stdin of 'grep'.

If you like, the 'pipe' command is the plumbing and Bash is the plumber.

Any data `ls` writes to it's stdout, is written to 'grep's stdin. We say that the two apps are  connected via a 'pipe'.

> **A 'pipe' is just a program that reads from one FD and writes to another.**&#x20;
>
> In this case Bash is acting as the pipe. When Bash sees the '|' character it takes it as an instruction to launch the two applications (ls and grep), read stdout from ls and write that data to grep's stdin.&#x20;

A couple of other interesting things happened here.

1\) stdin of `ls` is still connected to the terminal (`ls` is just ignoring it)

2\) stdout of `grep` is still connected to the terminal, anything that grep writes to its stdout will appear on the terminal.

## Revelations

{% hint style="warning" %}
You take the _red_ pill—you stay in Wonderland, and I show you how deep the rabbit hole goes.
{% endhint %}

So let's just stop for a moment and consider this fact; **the terminal you are using is actually an app!**

Like every other app, it has stdin/stdout/stderr.

When we run an app in a terminal window the app's:

* stdin is attached to the terminal's stdout
* stdout is attached to the terminal's stdin.
* stderr is attached to the terminal's stdin.

\[terminal -> stdout] => \[stdin -> app -> stdout, stderr] => \[stdin -> terminal]

{% hint style="info" %}
And so we are all connected in the great Circle of Life.

Mafasa, The Lion King.
{% endhint %}

So let's look at what happens when our app prints something.

> \[print('hello') -> stdout] => \[stdin -> terminal  font] => \[graphics card ] => \[eye -> brain]

When we call `print('hello')` our app writes 'hello' to stdout, this arrives in the terminal app via the terminal's stdin.

The terminal app then takes the ASCII characters we sent (hello), translates them to pixels and sends them to our graphics card.&#x20;

These pixel form, what many people like to call, a 'font'. Somehow, rather magically, your brain translates these little pixels into characters and you see the word 'hello'.

{% hint style="info" %}
In the beginning, was the Word, and the Word was 'hello world'.
{% endhint %}

The above example uses `print` to write to stdout. Print is a common function for writing to stdout and `print` or similar exists in most languages. Under the hood `print` literally writes to stdout:

If we look at the Dart implementation of `print,` the truth of this is self evident.

```
void print(String message)
{
    stdout.writeln(message);
}
```

{% hint style="info" %}
And you will know the truth, and the truth will set you free.

Some bloke.
{% endhint %}

## It's turtles, all the way down!

So I lied. But it was an honest lie...

Launching a terminal doesn't directly attach to our app as there is almost always a middleman.  That middleman is the shell.

The shell, as I'm sure you know, provides an interactive prompt allowing you to launch applications.

So my (small) lie can be fixed by adding the shell into the pipeline:

Instead of:

\[print('hello') -> stdout] => \[stdin -> terminal -> font] => \[graphics card ] => \[eye -> brain]

What really happens is:

\[print('hello') -> stdout]&#x20;

&#x20;   \=> \[stdin -> shell -> stdout]&#x20;

&#x20;       \=> \[stdin -> terminal -> font]&#x20;

&#x20;           \=> \[graphics card ]&#x20;

&#x20;               \=> \[eye -> brain]

Examples of shells are:&#x20;

Bash, Zsh, Powershell, CMD, Ash, Bourne, Korn, Hamilton...&#x20;

and of course, you could build your own.

{% hint style="info" %}
Is that a rhetorical point, or would you like to do the maths?&#x20;

Sheldon's Mother
{% endhint %}

OK, so let's do the maths and implement a basic shell.

You can find the complete code on github:  [https://github.com/onepub-dev/dshell](https://github.com/onepub-dev/dshell)

#### dshell.dart

```dart
#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dshell/src/app_with_args.dart';
import 'package:dshell/src/pipe.dart';

void main(List<String> args) async {
  // Loop, asking for user input and evaluate it
  for (;;) {
    // print pwd> as a prompt
    stdout.write('${green(basename(pwd))}${blue('>')}');
    final commandLine = stdin.readLineSync() ?? '';
    if (commandLine.isNotEmpty) {
      await evaluate(commandLine);
    }
  }
}

// Evaluate the user's input
Future<void> evaluate(String commandLine) async {
  // use the | to split out multiple commands
  final apps = commandLine.split('|');
  // just a single app, so run it.
  if (apps.length == 1) {
    runApp(AppWithArgs(apps[0]));
    return;
  }
  // if we see two apps use pipe 
  if (apps.length == 2) {
    final app1 = AppWithArgs(apps[0]);
    final app2 = AppWithArgs(apps[1]);

    await simplePipe(app1, app2);
  } else {
    stderr.writeln('We only support piping 2 apps');
  }
}

void runApp(AppWithArgs appWithArgs) {
  switch (appWithArgs.app) {
    // list files in the current directory
    case 'ls':
      ls(appWithArgs.args);
      break;

    // change directories
    case 'cd':
      Directory.current = join(pwd, appWithArgs.args[0]);
      break;

    // treat the first word as the name of an app
    // and run it.
    default:
      if (which(appWithArgs.app).found) {
        // The run command is part of DCli and does all of the
        // plumbing for stding/stdout/stderr.
        run(appWithArgs.cmdLine);
      } else {
        stdout.writeln(red('Unknown command: ${appWithArgs.app}'));
      }
      break;
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*',
            workingDirectory: pwd,
            recursive: false,
            types: [Find.file, Find.directory])
        .forEach((file) => stdout.writeln('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              workingDirectory: pwd,
              recursive: false,
              types: [Find.file, Find.directory])
          .forEach((file) => stdout.writeln('  $file'));
    }
  }
}


```

#### `pipe.dart`

The pipe function is where the funky stuff happens.

The simplePipe function runs each app and then wires their output together using dart's built-in pipe command. The pipe command simply reads `stdout` of the first app and writes that data into  `stdin` of the second app.

\[app1 -> stdout] => \[stdin -> app2]

Finally, the call to pipeNoClose  wires the output of the app2 is written directly to our shell's own `stdout`.&#x20;

\[app1 -> stdout] => \[stdin -> app2] => \[stdout(shell)]  => \[stdin -> terminal ....] => brain

The result is, that the data that app2 writes is displayed on the console (because the console is reading the shell's stdout).

This is essentially the same process used by any shell.

```dart
import 'dart:io';

import 'app_with_args.dart';

Future<void> simplePipe(AppWithArgs app1, AppWithArgs app2) async {
  final app1Process = await Process.start(app1.app, app1.args);
  final app2Process = await Process.start(app2.app, app2.args);

  // the output from app1 is sent to the input of app2
  await app1Process.stdout.pipe(app2Process.stdin).catchError(
    // ignore: avoid_types_on_closure_parameters
    (Object e) {
      // ignore broken pipe after app2 process exit
    },
    test: (e) =>
        e is SocketException &&
        (e.osError!.message == 'Broken pipe' ||
            e.osError!.message == 'StreamSink is closed'),
  );

  /// the output of app2 is sent to the console.
  /// We can't use the normal pipe command is it closes the consumer (stdout)
  /// would would stop our app from outputting any further
  await pipeNoClose(app2Process.stdout, stdout);
}

Future<void> pipeNoClose(Stream<List<int>> stdout, IOSink stdin) async {
  await stdin.addStream(stdout);
}

```

If you clone and run the above Dart script, you get an interactive shell. Here is a sample session:

```bash
git clone https://github.com/onepub-dev/dshell.git
cd dshell
dart bin/dshell.dart 
example> ls
  dshell.dart
example> mkdir tmp
example> cd tmp
tmp> touch me
tmp> ls
  me
tmp> cd ..
example> ls
  dshell.dart
  tmp
example> cat bin/dshell.dart | grep pipe
   import 'package:dshell/src/pipe.dart';
   await pipe(app1, app2);
```

## And a word from our sponsors

This Blog and DCli are sponsored by [OnePub](https://onepub.dev/drive/3aacb2de-3eb5-4cc5-90f3-60347aa2dc11).

OnePub is a private package repository for Dart.

If you want to try OnePub, you can publish our sample shell application in a few lines:

```bash
dart pub global activate onepub
onepub login
git clone https://github.com/onepub-dev/dshell.git
cd dshell
onepub pub private
dart pub publish
```

You can now install your own shell anywhere you have Dart.

```bash
onepub pub global activate dshell
```

OnePub is currently in beta (as of Aug 2022). Whilst in Beta, anyone that publishes a package to OnePub will receive a free lifetime subscription.

### Its turtles all the way down

So let's look at what actually happens when you launch a terminal window or connect to a console.

When the terminal window launches it creates a canvas to display text and starts listening to keystrokes. If the terminal window has the focus then the OS will send keystrokes to it, otherwise, it gets nothing. The terminal launches your default shell as a child process. Let's call this shell `Bash` but it could be called `Powershell`.

When Bash is launched, it, like every other app, receives three file descriptors stdin/stdout and stderr.

The terminal window, being an app, also has its own stdin/stdout and stderr.

When we launch a CLI app its stdin is attached to the Terminal (via the shell).

It's actually the terminal app that is responsible for interacting with the keyboard.

When the terminal app gains focus it is attached to the system message queue (allowing it to receive keystrokes) and the terminal app writes characters to our CLI app's stdin (via the shell).

\[brain -> fingers] -> \[keyboard -> system queue] -> \[terminal app] -> \[shell] -> \[stdin of our CLI app]

### Stdin

Let's recap.

* Stdin allows an app to take input from the user or another app.
* Because it's a standard, tools like Bash can reliably use it to wire apps together.
* You can't assume that your app's stdin is only taking data from the keyboard it could be another app.
* Many apps provide an interactive and non-interactive mode to cater for the different ways that it can be launched.
* This doesn't mean that you have to handle data coming from a user or another app. If those modes don't suit the purpose of your app you can just ignore stdin.
* Whilst not discussed here, stdin usually operates in line mode with the shell echoing all typed characters to the console. In most languages, you can switch off echo mode (for password capture etc)  as well as switching to non-line mode.
* You can't use a 'seek' on stdin to change the file read position.

{% hint style="info" %}
In DCli we use the `ask` function which provides a high-level wrapper for readLineSync.

var name = ask('Enter your name:');
{% endhint %}

## Stdout

Most languages provide a **print** and often a **println** function, both of which write to stdout.

Normally, print will print without a terminating newline, whilst println includes a terminating newline.

In Dart, we only have the print function (which includes a terminating newline) but DCli adds an 'echo' function that allows you to control if a newline is added.

You can of course write directly to stdout.

## Stderr

Most languages don't provide a method to easily write to stderr. You will generally need to write something like:

`stderr.write('bad times, where had by all');`

The DCli package adds the `printerr` function which works exactly like print does, but prints to stderr.

## Conclusion

Well, that was quite a trip. Hopefully, it fills some gaps and puts you on a path to building better CLI tooling.

The OnePub Blog - [The Dart Side](https://onepub.dev/drive/9a6ed12b-5ae2-4299-b182-e97f078dd689) has additional articles on CLI programming

