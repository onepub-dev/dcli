# stdin/stdout/stderr a primer

When building console apps you are going to hear a lot about three little entities: stdin, stdout and stderr.

In the Linux, Windows and OSX world any time you launch an application three file descriptors are automatically opened and attached to the application.

I refer to these three file descriptors as 'the holy trinity'. If you are going to do Command Line Interface \(CLI\) programming then it is imperative that you understand what they are and how to use them.

This primer discusses the origins, the structure and finally how to interact with the holy trinity in CLI apps.

{% hint style="info" %}
stdin/stdout/stderr are not unique to dart. Virtually every langue supports them.
{% endhint %}

## In the beginning

Let's take a little history lesson.

Way back in the dark ages \(circa 1970\) the computer gods got together and created Unix.

{% hint style="info" %}
And Dennis said let there be 'C'. And Denis looked upon 'C' and said it was good and the people agreed.

But Dennis did not rest on the seventh day, instead he called upon Kenneth and over lunch they doth created Unix.

Dennis Ritchie ; 9th Sept 1944 - 12th Oct 2011  
Kenneth Lane Thompson February 4, 1943 
{% endhint %}

![My first bible.](../.gitbook/assets/image%20%281%29%20%281%29.png)

Unix is the direct ancestor of Linux, OSX and to a lesser extent Windows. You might more correctly say that 'C' is the common ancestor of all three OSs as their kernels are all written in C.

The concept of stdin/stdout and stderr proliferated across the OS world as C was taken up as the primary language for writing Operating Systems.

The result is today that a large no. of operating systems support stdin/stdout and stderr in all CLI applications.

The majority of people reading this primer will be working with Linux, OSx or Windows and in each of these cases the Holy Trinity \(stdin/stdout/stderr\) are available in every CLI app they use or write.

The following examples are presented using the Dart programming language but the concepts and even most of the details are correct across multiple OSs and languages.

## When you have a hammer, everything's a snail

In the Unix world EVERYTHING is a file. Even devices and processes are treated as files.

{% hint style="info" %}
If you know where to look, processes and devices are actually visible in the Linux/OSx directory tree as files.
{% endhint %}

So if everything is a file, does that mean we can directly read/write to a device/process/directory ....?

The simple answer is yes.

If we want to read/write to a file we need to open the file. In the Unix world \(and virtually every other OS\) when we open a file we get a 'file descriptor' or FD for short. Once we have an FD we can read/write to the file. The FD may be presented differently in your language of choice but under the hood its still an FD. \(**In Dart we have the File class that wraps an FD**\).

> The terms 'file descriptor' and 'file handle' are often used interchangeably.

So what exactly is an FD? Under the hood an FD is just an integer that acts as an index to an array of open files. The FD array contains information such as the path to the file, the size of the file, the current seek position and more.

## The Holy Trinity

So now we understand that in Unix everything is a file, you probably won't be surprised when I tell you that stdin/stdout/stderr are also files.

So if stdin/stdout/stderr are files how do you open them?

The answer is you don't need to open them as the OS opens them for you. When your app starts, it is passed one file descriptor \(FD\) for each of stdin/stdout/stderr.

If you recall we said that an FD is just an integer indexing into an array of structures, with one array entry for each open file. Each application has its own array. When your app starts that array already has three entries, stdin, stdout and stderr.

The order of those entries in the array is important.

\[0\] = stdin

\[1\] = stdout

\[2\] = stderr.

If you open any additional files they will appear as element \[3\] and greater.

## The tower of Babel

If you have done any Bash, Zsh or Powershell programming you may have seen a line similar to:

```text
find . '*.png' >out.txt 2>&1
```

You can't get much more obtuse than the above line, but now we know about FD's it actually makes a little more sense.

{% hint style="warning" %}
Bash was not created by the gods. I think the other bloke had a hand in this one.
{% endhint %}

The `>out.txt` section is actually a shorthand for `1>out.txt` . It instructs Bash to take anything that `find` writes to FD =1 \(stdout\) and re-write it to the file called 'out.txt'.

The `2> &1` section instructs Bash to take anything `find` writes to FD=2 \(stderr\) and re-write it to FD=1. i.e. anything written to stderr \(FD=2\) should be re-written to stdout \(FD=1\).

The result of the above command is that both stdout and stderr are written to the file called 'out.txt'.

It would have been less obtuse to write:

```text
find . '*.png' 1>out.txt 2>out.txt
```

But of course we are talking about Bash here and apparently more obtuse is always better :\)

* Many other shells use a similar syntax.

Most languages provide a specific wrapper for each these file handles. In Dart we have the global properties:

* stdin
* stdout
* stderr

> The 'C' programming language has the same three properties and many other languages use the same names.

## And on this rock I will build my app

I like to think of the Unix philosophy as programming by Lego.

{% hint style="info" %}
Unix was all about Lego - build lots of little bricks \(apps\) that can be connected.
{% endhint %}

In the Unix world \(and the dart world\) every CLI app you write contributes to the set of available Lego bricks. But Lego bricks would be useless unless you can connect them. In order to connect bricks the 'pegs' on each brick must match the 'holes' on other bricks and that's where stdin/stdout/stderr come in.

In the Unix world every brick \(app\) has three connection points:

* stdin - a hole for input 
* stdout - a peg for normal output
* stderr - a peg for error output

Any peg can go into any hole.

You might now have guessed that you can connect stdout from one program to stdin on another program:

\(myapp -&gt; stdout\) -&gt; \(stdin -&gt; yourapp\)

If you are familiar with Bash you may have even seen one of the common ways to connect two apps.

```text
ls "*.png" | grep "pengiuns"
```

The '\|' pipe operator connects the stdout of 'ls' to the stdin of 'grep'.

If you like, the 'pipe' command is the plumbing and Bash is the plumber.

Any data `ls` writes to it's stdout, is written to 'grep's stdin. The two apps are now connected via a 'pipe'.

> A 'pipe' is just a program that reads from one FD and writes to another. When Bash sees the '\|' character it takes it as an instruction to launch the two applications \(ls and grep\) read stdout from ls and write that data to stdin of grep.

A couple of other interesting things happened here.

1\) stdin of `ls` is still connected to the terminal \(`ls` is just ignoring it\)

2\) stdout of `grep` is still connected to the terminal anything that grep writes to its stdout will appear on the terminal.

### Implement a shell

To make the whole concept a little more concrete we are going to implement a toy shell replacement for Bash.

Bash, Powershell and every other shell implement a read–eval–print loop \(REPL\).

**R**ead input from the user, **E**valuate the input \(execute it\), **P**rint the results, **L**oop and do it again.

It turns it that its really easy to implement your own toy shell. So let's do it in just 50 lines of code.

```dart
#! /usr/bin/env dcli

import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    var line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}
// Evaluate the users input
void evaluate(String command) {
  var parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
      break;
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
    default:
      if (which(parts[0]).found) {
        command.run;
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
            root: pwd,  recursive: false,
            types: [Find.file, Find.directory])
        .forEach((file) => print('  $file'));
  } else {
    for (var pattern in patterns) {
      find(pattern, root: pwd,  recursive: false, types: [
        Find.file,
        Find.directory
      ]).forEach((file) => print('  $file'));
    }
  }
}
```

If you save and run the above Dart script you will get an interactive shell. Here is a sample session:

```bash
./dshell.dart 
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

### Implement a pipe

Now we have a basic shell let's extend it to implement a pipe.



## Revelations

{% hint style="warning" %}
You take the _red_ pill—you stay in Wonderland, and I show you how deep the rabbit hole goes.
{% endhint %}

So lets just stop for a moment and consider this fact; **the terminal you are using is actually an app!**

Like every other app it has stdin/stdout/stderr.

### Writing to stdout

When you run an app in a console/terminal window your app's stdout is automatically piped to the terminal's stdin.

> \[print\('hellow'\) -&gt; stdout\] -&gt; \[stdin -&gt; terminal -&gt; font -&gt; graphics card -&gt; eye -&gt; brain\]

When you call `print('hello')` your app writes 'hello' to stdout, this arrives in the terminal app via its stdin.

The terminal app then takes the ASCII characters you sent \(hello\) and sends little blobs of pixels to your graphics card. These blobs of pixel form, what many people like to call, a 'font'. Somehow, rather magically, your brain translates this little pixels into characters and you see the word 'hello'.

{% hint style="info" %}
In the beginning was the Word, and the Word was 'hello world'.
{% endhint %}

The above example uses `print` to write to stdout. Print is a common function for writing to stdout and `print` or similar exists in most languages. Under the hood `print` literally writes to stdout:



So where does stderr fit in?

```text
void print(String message)
{
    stdout.write('message\n');
}
```

Well yes, I did, but it was a morally sound lie. I really wanted to avoid melting your brain.

{% hint style="info" %}
And you will know the truth, and the truth will set you free.”
{% endhint %}

When your app is launched from the CLI \(command line interface\) your app is actually connected to the shell that launched. It doesn't matter if the shell was Bash, Powershell or Zsh.

> In case you skipped the class, a command line interface \(CLI\) is a type of application referred to as a shell. A shell is designed to take keystrokes from a user, echo those keystrokes to the screen and when the user hits the enter key, try to interpret those keystrokes as a command. Often the command will be the name of an application, in which case the shell will start that application. Examples of shells are: Bash, Zsh, Powershell, cmd, Ash, Bourne, Korn, Hamilton............. and of course you could build your own.

So lets look at what actually happens when you launch a terminal window or connect to a console.

When the terminal window launches it creates a canvas to display text on and starts listening to keystrokes. If the terminal window has the focus then the OS will send keystrokes to it, otherwise it gets nothing.  It then launches your default shell as a child process. Let's call this shell `Bash`  but it could be called `Powershell`.

When Bash is launched it of course receives three file descriptors stdin/stdout and stderr.

The terminal window, being an app, also has its own stdin/stdout and stderr, but it essentially ignores them and they don't play a part in our process.

### Reading from stdin



```text
import 'dart:io';

void main() {
  stdout.writeln('Type something');
  String input = stdin.readLineSync();
  stdout.writeln('You typed: $input');
}
```



So by default 'find''s stderr is also connected to 'greps' stdin. The pipe ''\|' is doing this for use by interleaving stdout and stderr from 'find' into 'grep's stdin.



If you recall earlier we mentioned that most classes provide a wrapper for each of the holy trinity.

You can however separate stderr and stdout and read them independently.

So when we call:

```text
printerr('An error occured');
```

A program reading our stderr can process this separately.

## Stdout

Stdout is the easiest to understand so let's start here.

In the classic hello world program, exactly how is the 'hello world' displayed to the user?

To put it simply; when you 'print' the string 'hello world', the print function writes 'hello world' to the file handle 'stdout'.

```text
print('hello world');
```

## Stdin

If stdout is used to send data to the terminal, then stdin is used to receive data from the terminal.

More correctly we say that we write data to stdout and read data from stdin.

So if we want to capture what the user is typing into the terminal then we need to 'read' from stdin.

```text
 user -&gt; hello -&gt; terminal -&gt; stdin -&gt; read
```

Dart actually provides low level methods to directly read from stdin but their a little bit painful to work with.

As DCli likes to make things easy we provide the 'ask' function which does the hard work of reading from stdin.

```text
String username = ask('username:');
```

The 'ask' function prints 'username:' to stdout, then sits in a loop reading from 'stdin' until the user hits the enter key. When the user hits the enter key we return the anything they typed \(and we read from stdin\) and it is assigned to the variable 'String username';

## Stderr

So stderr is both simple and complex.

Its simple in that by default it works just like stdout. If you write to stderr then it will appear on the console just the same as stdout. If fact a user can't tell the difference.

DCli provides a function to let you write to stderr:

```text
printerr('hello world');
```

So if it looks the same to the user why do we have both stdout and stderr?

