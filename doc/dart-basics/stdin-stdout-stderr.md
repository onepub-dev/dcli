# stdin/stdout/stderr

When building console apps you are going to here a lot about three little entities: stdin, stdout, stderr.

In the Linux, Windows and OSX world any time you launch an application three file handles are automatically opened and attached to the application.

In GUI application these file handles are pretty much ignored. In a Console application they are critical.

{% hint style="info" %}
stdin/stdout/stderr are not unique to dart. Virtually every langue supports them.
{% endhint %}

## Stdout

Stdout is the easiest to understand so let's start here.

In the classic hello world program, exactly how is the 'hello world' displayed to the user?

To put it simply; when you 'print' the string 'hello world', the print function writes 'hello world' to the file handle 'stdout'.

```text
print('hello world');
```

We use the term 'file handle' rather than file as 'stdout' isn't a file but rather one end of a connection or in the linux world, one end of a 'pipe'.

The stdout file handle is connected to your terminal window. Anything written to the stdout file handle is sent down the pipe and gets displayed on your terminal.

    print 'hello' -&gt; stdout -&gt; terminal -&gt; hello -&gt; user

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

Let's take a little history lesson.

Way back in the dark ages \(circa 1970\) the computer gods got together and created Unix.

{% hint style="info" %}
These are some of the same gods that created 'C'.
{% endhint %}

Unix is the direct ancestor of Linux, OSX and to a lesser extent Windows.

I like to think of the Unix philosophy as programming by Lego.

{% hint style="info" %}
Unix was all about Lego - build lots of little bricks \(apps\) that can be connected \(by pipes\).
{% endhint %}

In the Unix world \(and the dart world\) every CLI app you write contributes to the set of available Lego bricks.  But Lego bricks would be useless unless you can connect them. In order to connect them the 'pegs' on each brick must match the 'holes' on the other bricks and that where stdin/stdout/stderr come in.

In the Unix world every brick \(app\) has three connection points: 

* stdin - a hole for input 
* stdout - a peg for output
* stderr - a peg for error ouput

Any peg can go into any hole.

You might now have guess that you can connected stdout from one program to stdin on another program:

myapp -&gt; stdout -&gt; stdin -&gt; yourapp

If you are familiar with bash you may have even seen one way of connecting two apps using the pipe '\|' character:

find / -name "\*.png" \| grep "pengiuns"

The '\|' pipe operator connects the stdout of 'find' to the stdin of 'grep'.

Now that they are connected any data 'find' writes to it's stdout, is written to 'grep's stdin. The two apps are now connected.

A couple of other interesting things happened here.

1\) stdin of find is still connected to the terminal \(find is just ignoring it\)

2\) stdout of grep is still connected to the terminal anything that grep writes to its stdout will appear on the terminal.

So where does stderr fit in?

So by default 'find''s stderr is also connected to 'greps' stdin. The pipe ''\|' is doing this for use by interleaving stdout and stderr from 'find' into 'grep's stdin.

You can however separate stderr and stdout and read them independently.

So when we call:

```text
printerr('An error occured');
```

A program reading our stderr can process this separately.



