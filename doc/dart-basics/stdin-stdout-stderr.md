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

But these files are anything but basic.

## In the beginning

Let's take a little history lesson.

Way back in the dark ages (circa 1970) the computer gods got together and created Unix.

{% hint style="info" %}
And Dennis said, let there be 'C'. And Denis looked upon 'C' and said it was good and the people agreed.

But Dennis did not rest on the seventh day, instead he called upon Kenneth and over lunch and a nice red, they doth created Unix.

Dennis Ritchie ; 9th Sept 1944 - 12th Oct 2011\
Kenneth Lane Thompson February 4, 1943
{% endhint %}

![My first bible.](<../.gitbook/assets/image (1) (1) (1) (1) (2).png>)

Unix is the direct ancestor of Linux, MacOS and to a lesser extent Windows. You might more correctly say that 'C' is the common ancestor of all three OSs, as their kernels are all written in C.

The concept of stdin/stdout and stderr proliferated across the OS world as C was taken up as the primary language for writing Operating Systems.

The result is today that a large no. of operating systems support stdin/stdout and stderr.

The majority of people reading this primer will be working with Linux, MacOS or Windows and in each of these cases the Holy Trinity (stdin/stdout/stderr) are available in every app they use or write.

The following examples are presented using the Dart programming language, but the concepts and even most of the details are correct across multiple OSs and languages.

## When you have a hammer, everything's a snail

In the Unix world, EVERYTHING is a file. Even devices and processes are treated as files.

{% hint style="info" %}
If you know where to look, processes and devices are actually visible in the Linux/MacOS directory tree as files.
{% endhint %}

So if everything is a file, does that mean we can directly read/write to a device/process/directory?

The simple answer is, yes.

If we want to read/write to a file we need to open the file. In the Unix world (and virtually every other OS) when we open a file we get a 'file descriptor' or FD for short. Once we have an FD we can read/write to the file. The FD may be presented differently in your language of choice but under the hood its still an FD. (**In Dart we have the File class that wraps an FD**).

> The terms 'file descriptor' and 'file handle' are often used interchangeably.

So what exactly is an FD? Under the hood an FD is just an integer that acts as an index to an array of open files. The FD array contains information such as the path to the file, the size of the file, the current seek position and more.

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

The `>out.txt` section is actually a shorthand for `1>out.txt` . It instructs Bash to take anything that `find` writes to FD =1 (stdout) and and re-write it to the file called 'out.txt'.

The `2> &1` section instructs Bash to take anything `find` writes to FD=2 (stderr) and re-write it to FD=1.&#x20;

i.e. anything written to stderr (FD=2) then re-write it to stdout (FD=1) which in turn is written to `out.txt`.  &#x20;

The result of the above command is that both stdout and stderr are written to the file called 'out.txt'.

It would have been less obtuse to write:

```
find . '*.png' 1>out.txt 2>out.txt
```

But of course we are talking about Bash here and apparently more obtuse is always better :)

> Many other shells use a similar syntax.

Most languages provide a specific wrapper for each these file handles. In Dart we have the global properties:

* stdin
* stdout
* stderr

> The 'C' programming language has the same three properties and many other languages use the same names.

## And on this rock I will build my app

I like to think of the Unix philosophy as programming by Lego.

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

\[myapp -> stdout] -> \[stdin -> yourapp]

If you are familiar with Bash you may have even seen one of the common ways to connect two apps.

```
ls "*.png" | grep "penguins"
```

In the above example the `ls` command will write a list of files that end in `.png`. The grep command will receive that list and then output a line each time it sees a filename that contains the word `penguins`.

The '|' pipe operator connects the stdout of 'ls' to the stdin of 'grep'.

If you like, the 'pipe' command is the plumbing and Bash is the plumber.

Any data `ls` writes to it's stdout, is written to 'grep's stdin. We say that the two apps are  connected via a 'pipe'.

> A 'pipe' is just a program that reads from one FD and writes to another. In this case Bash is acting as the pipe. When Bash sees the '|' character it takes it as an instruction to launch the two applications (ls and grep), read stdout from ls and write that data to stdin of grep.&#x20;

A couple of other interesting things happened here.

1\) stdin of `ls` is still connected to the terminal (`ls` is just ignoring it)

2\) stdout of `grep` is still connected to the terminal, anything that grep writes to its stdout will appear on the terminal.

## Revelations

{% hint style="warning" %}
You take the _red_ pill—you stay in Wonderland, and I show you how deep the rabbit hole goes.
{% endhint %}

So let's just stop for a moment and consider this fact; **the terminal you are using is actually an app!**

Like every other app it has stdin/stdout/stderr.

When we run an app in a terminal window the app's:

* stdin is attached to the terminal's stdout
* stdout is attached to the terminal's stdin.
* stderr is attached to the terminal's stdin.

So let's look what happens when our app prints something.

> \[print('hello') -> stdout] -> \[stdin -> terminal -> font] -> \[graphics card ] -> \[eye -> brain]

When we call `print('hello')` our app writes 'hello' to stdout, this arrives in the terminal app via its stdin.

The terminal app then takes the ASCII characters we sent (hello), translates them to pixels and sends them to our graphics card. These pixel form, what many people like to call, a 'font'. Somehow, rather magically, your brain translates this little pixels into characters and you see the word 'hello'.

{% hint style="info" %}
In the beginning was the Word, and the Word was 'hello world'.
{% endhint %}

The above example uses `print` to write to stdout. Print is a common function for writing to stdout and `print` or similar exists in most languages. Under the hood `print` literally writes to stdout:

The Dart implementation of `print` now makes sense:

```
void print(String message)
{
    stdout.write('$message\n');
}
```

{% hint style="info" %}
And you will know the truth, and the truth will set you free.”
{% endhint %}

## Turtles also have shells

So I lied. But it was a honest lie...

When we launch a terminal it typically doesn't directly attached to our app as there is almost always a middle man.  That middle man is the shell.

The shell, as I'm sure you known, provides an interactive&#x20;



Examples of shells are:&#x20;

Bash, Zsh, Powershell, CMD, Ash, Bourne, Korn, Hamilton...&#x20;

and of course you could build your own.

{% hint style="info" %}
Is that a rhetorical point, you would you like to do the maths?&#x20;

Sheldon's Mother
{% endhint %}

> OK, so let's do the maths and implement a basic shell.

```dart
#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    // print a > as a prompt
    stdout.write('${green(basename(pwd))}${blue('>')}');
    final line = stdin.readLineSync() ?? '';
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}

// Evaluate the users input
void evaluate(String command) {
  final parts = command.split(' ');
  switch (parts[0]) {
    // list files in the current directory
    case 'ls':
      ls(parts.sublist(1));
      break;

    // change directories
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;

    // treat the first word as the name of an app
    // and run it.
    default:
      if (which(parts[0]).found) {
        // The run command is part of DCli and does all of the
        // plumbing for stding/stdout/stderr.
        run(command);
      } else {
        print(red('Unknown command: ${parts[0]}'));
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
        types: [Find.file, Find.directory]).forEach((file) => print('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              workingDirectory: pwd,
              recursive: false,
              types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
  }
}

```

If you save and run the above Dart script, you get an interactive shell. Here is a sample session:

```bash
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
example>
```

You can find the complete code on github:  [https://github.com/onepub-dev/dshell](https://github.com/onepub-dev/dshell)

### Its turtles all the way down

So lets look at what actually happens when you launch a terminal window or connect to a console.

When the terminal window launches it creates a canvas to display text  and starts listening to keystrokes. If the terminal window has the focus then the OS will send keystrokes to it, otherwise it gets nothing. The terminal launches your default shell as a child process. Let's call this shell `Bash` but it could be called `Powershell`.

When Bash is launched, it, like every other app, receives three file descriptors stdin/stdout and stderr.

The terminal window, being an app, also has its own stdin/stdout and stderr.

When we launch a CLI app it's stdin is attached to the Terminal.

It's actually the terminal app that is responsible for interacting with the keyboard.

The terminal app is attached to a system message queue and the terminal app writes characters to our CLI app's stdin.

\[brain -> fingers] -> \[keyboard -> system queue] -> \[terminal app] -> \[stdin of our CLI app]

In the above example when we call `stdin.readLineSync()` we are reading characters written to our stdin via the terminal.

### Reading from stdin

```
import 'dart:io';

void main() {
  stdout.writeln('Type something');
  String input = stdin.readLineSync();
  stdout.writeln('You typed: $input');
}
```



Of course someone could just as easily add our app to a pipe line:

```bash
find *.txt | ourapp
```

In this case when our app calls `stdin.readLineSync()` it is reading the data that `find` writes its stdout which the pipe command attaches to our stdin.

If you recall earlier we mentioned that most classes provide a wrapper for each of the holy trinity.

You can however separate stderr and stdout and read them independently.

So when we call:

```
printerr('An error occured');
```

A program reading our stderr can process this separately.

## Stdout

Stdout is the easiest to understand so let's start here.

In the classic hello world program, exactly how is the 'hello world' displayed to the user?

To put it simply; when you 'print' the string 'hello world', the print function writes 'hello world' to the file handle 'stdout'.

```
print('hello world');
```

## Stdin

If stdout is used to send data to the terminal, then stdin is used to receive data from the terminal.

More correctly we say that we write data to stdout and read data from stdin.

So if we want to capture what the user is typing into the terminal then we need to 'read' from stdin.

```
 user -> hello -> terminal -> stdin -> read
```

Dart actually provides low level methods to directly read from stdin but their a little bit painful to work with.

As DCli likes to make things easy we provide the 'ask' function which does the hard work of reading from stdin.

```
String username = ask('username:');
```

The 'ask' function prints 'username:' to stdout, then sits in a loop reading from 'stdin' until the user hits the enter key. When the user hits the enter key we return the anything they typed (and we read from stdin) and it is assigned to the variable 'String username';

## Stderr

So stderr is both simple and complex.

Its simple in that by default it works just like stdout. If you write to stderr then it will appear on the console just the same as stdout. If fact a user can't tell the difference.

DCli provides a function to let you write to stderr:

```
printerr('hello world');
```

So if it looks the same to the user why do we have both stdout and stderr?
