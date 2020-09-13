# stdin/stdout/stderr a primer

When building console apps you are going to hear a lot about three little entities: stdin, stdout and stderr.

In the Linux, Windows and OSX world any time you launch an application three file descriptors are automatically opened and attached to the application.

I refer to these three file descriptors as 'the holy trinity'. If you are going to do cli programming then it is imperative that you understand what they are and how to use them.

This primer discusses the origins, the structure and finally how to interact with the holy trinity of cli apps.

{% hint style="info" %}
stdin/stdout/stderr are not unique to dart. Virtually every langue supports them.
{% endhint %}

If you want to program cli apps, then you must understand what these three file descriptors are and what they do.

## In the beginning

Let's take a little history lesson.

Way back in the dark ages \(circa 1970\) the computer gods got together and created Unix.

{% hint style="info" %}
And Dennis said let there be 'C'. And Denis looked upon 'C' and said it was good and the people agreed.

But Dennis did not rest on the seven day, instead he called Ken and over lunch created Unix.

Dennis Ritchie ; 9th Sept 1944 - 12th Oct 2011
{% endhint %}

![My first bible.](../.gitbook/assets/image.png)

Unix is the direct ancestor of Linux, OSX and to a lesser extent Windows. You might more correctly say that 'C' is the common ancestor of all three OSs  as their kernels are written in C.

## File Descriptors

In the Unix world EVERYTHING is a file. Even devices and processes are treated as files.

{% hint style="info" %}
If you know where to look, running processes and devices are actually visible in the Linux/OSx directory tree as files!
{% endhint %}

So if everything is a file, does that mean we can directly read/write to a device/process/directory ....? 

The simple answer is yes. 

If we want to read/write to a file we need to open the file. In the Unix world \(and virtually every other OS\) when we open a file we get a 'file descriptor' or FD for short. Once we have an FD we can read/write to the file. The FD may be presented differently in your language of choice but under the hood its still an FD. \(**In Dart we have the File class that wraps an FD**\).

> The terms 'file descriptor' and 'file handle' are often used interchangeably.

So what exactly is an FD? Under the hood an FD is just an integer that acts as a index to an array of open files. The FD array contains information such as the path to the  file, the size of the file, the current seek position...

## The Holy Trinity

So now we understand that in Unix everything is a file, you probably won't be surprised when I tell you that stdin/stdout/stderr are also files.  

So if stdin/stdout/stderr are files how do you open them? 

You don't need to open them as the OS opens them for you. When your app starts, it is passed one file descriptor \(FD\) for each of stdin/stdout/stderr.

If you recall we said that FD's are just integers into an array of open files. Each application has its own array.  When your app starts that array already has three entries, stdin, stdout and stderr.

The order of those entries in the array is important.

\[0\] = stdin

\[1\] = stdout

\[2\] = stderr.

If you open any additional files they will appear as element \[3\] and greater.

## The tower of Babel

If you have done any Bash programming you may have seen a line like:

```text
find . '*.png' >out 2>&1
```

You can't get much more obtuse than the above line, but now we know about FD's it actually makes a little more sense.

{% hint style="warning" %}
Bash was not created by the gods. I think the other bloke had a hand in this one.
{% endhint %}

The `>out` is actually a shorthand for  `1>out` .  It instructs Bash to take anything that `find` writes to FD =1 and re-write it to the file called 'out'.  i.e. anything  `find` writes to sdtout \(FD=1\) should be rewritten to the file called 'out'.

The `2> &1` instructs bash to take anything `find` writes to FD=2 and re-write it to FD=1. i.e. anything written to stderr \(FD=2\) should be re-written to stdout \(FD=1\).  

The result of the above command is that both stdout and stderr are written to the file called 'out'.

It would have been less obtuse to write:

```text
find . '*.png' 1>out 2>out
```

But of course we are talking about Bash here and apparently more obtuse is always better :\)

* Many other shells use a similar syntax.

Most languages provide specific wrapper for each these file handles. In Dart we have the properties:

* stdin
* stdout
* stderr

The 'C' programming language has the same three properties and many other languages use the same names.

## And on this rock I will build my app

I like to think of the Unix philosophy as programming by Lego.

{% hint style="info" %}
Unix was all about Lego - build lots of little bricks \(apps\) that can be connected.
{% endhint %}

In the Unix world \(and the dart world\) every CLI app you write contributes to the set of available Lego bricks.  But Lego bricks would be useless unless you can connect them. In order to connect them the 'pegs' on each brick must match the 'holes' on the other bricks and that where stdin/stdout/stderr come in.

In the Unix world every brick \(app\) has three connection points: 

* stdin - a hole for input 
* stdout - a peg for output
* stderr - a peg for error output

Any peg can go into any hole.

You might now have guess that you can connect stdout from one program to stdin on another program:

\(myapp -&gt; stdout\) -&gt; \(stdin -&gt; yourapp\)

If you are familiar with bash you may have even seen one way of connecting two apps using the pipe '\|' character:

```text
ls "*.png" | grep "pengiuns"
```

The '\|' pipe operator connects the stdout of 'ls' to the stdin of 'grep'.

Any data `ls` writes to it's stdout, is written to 'grep's stdin. The two apps are now connected via a 'pipe'.

> A 'pipe' is just a program that reads from one FD and writes to another. In this case Bash is acting as the pipe. If your app reads from stdin and then writes to stdout or stderr then your app can act as a pipe.

A couple of other interesting things happened here.

1\) stdin of `ls` is still connected to the terminal \(`ls` is just ignoring it\)

2\) stdout of `grep` is still connected to the terminal anything that grep writes to its stdout will appear on the terminal.

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

The terminal app then takes the ASCII characters you sent \(hello\) and sends little blobs of pixels to your graphics card. These blobs of pixel form, what many people like to call, a 'font'.  Somehow, rather magically, your brain translates this little pixels into characters and you see the word 'hello'.

{% hint style="info" %}
In the beginning was the Word, and the Word was 'hello world'.
{% endhint %}





So where does stderr fit in?

So by default 'find''s stderr is also connected to 'greps' stdin. The pipe ''\|' is doing this for use by interleaving stdout and stderr from 'find' into 'grep's stdin.

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

     user -&gt; hello -&gt; terminal -&gt; stdin -&gt; read

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



