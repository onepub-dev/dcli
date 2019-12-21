# DShell - a bash replacement using dart

# Contents
* [Overview](#overview)
* [So why DShell](#so-why-dshell)
* [What does DShell do?](#what-does-dshell-do)
* [What commands does DShell support?](#what-commands-does-dshell-support)
* [Using DShell functions](#using-dshell-functions)
* [Running a script](#running-a-script)
* [Calling cli applications](#calling-cli-applications)
* [Piping](#piping)
* [Installing](#installing)
* [Running scripts](#running-scripts)
* [External packages](##external-packages)
* [Multi-file scripts](#multi-file-scripts)
* [Compiling to Native Executable](#compiling-to-native-executable)
* [Contributing](#contributing)
* [References](#references)

# Overview

DShell is intended to provide a replacement for bash and similar shell scripting languages with a Dart based scripting tool.

Bash has been the 'go to tool' for scripting file system operations for decades and it provides a wealth 
of really useful features.

Bash exemplifies the unix philosophy of Lego. The building of small, simple, re-usable blocks (applications) that can be coupled together to solve complex problems.

Bash's power lies in its ability to chain multiple commands together to provide a quick (and often dirty) solution.

Bash has an elegant set of commands for common file operations such as mv, cp, rm etc.

## So why DShell?

Whilst Bash is a powerful tool, it has a grammar that would make your Grandma blush.

**Its usage of quotes can only be described as..., oh wait, it so complex it's indescribable.**

For a long time I've wanted to build a replacement tool that has the elegance of a modern language, with the power of bash.

DShell is hopefully that.

## What does DShell do?

* Uses the elegant and simple dart language
* Write and execute single file scripts
  * cli> ./tryme.dart
* Provides a set of functions (commands) that mimick common bash operations.
* Allows for simple manipulation of files and directories
  * move(from, to), createDir(path), cd(path)...
* Allows you to call any cli application in a single line

  * 'grep error /var/lib/syslog'.run
* Process the output of a cli command.
  * 'grep error /var/lib/syslog'.forEach((line) => print(line));
* Chain multiple cli commands using pipes
  * 'grep error /var/lib/syslog' |'head 5'.forEach((line) => print(line));

* executes commands synchronously, so no need to worry about futures.

## What commands does DShell support?

DShell ships with a number of built in functions and the abilty to call any cli application and easily process the output.

These are some of the built-in commands:
* move(from, to)
* copy(from, to)
* delete(path)
* cd(path)
* push(path)
* pop()
* echo(text)
* sleep(duration)
* cat(file)
* find(pattern, {bool recursive})
* createDir(path)
* deleteDir(path)
* pwd
* ask({String prompt})
* read
* touch(path)
* basename(path)
* filename(path)
* extension(path)


# Getting Started
## Installing

To install DShell run:

```shell
pub global activate dshell

```

Note: I had a problem with my installation where the flutter internal verion of the dart-sdk was
on my path before the os version. I don't believe the flutter dart-sdk should be on your path.
Removing it from my path allowed me to developed cli apps as well as flutter.

## Writing your first script


Let's start with the classic hello_world.dart

Create a file called `hello_world.dart`.

Copy the following contents to the script.

```dart
void main() {
    print('hello world');
}
```

Now run the script.

```
cli> dshell hello_world.dart
Resolving dependancies....
hello world
cli>
```

The first time you run a given DShell script DShell needs to resolve any dependancies by running a  `pub get` command and doing some other house keeping.

If you run the same script a second time DShell as already resolved the dependancies and so it can run the script immediately.


```
cli>dshell hello_world.dart
hello world
cli>
```


So far this is just a normal dart library that you can run directly from the command line.

The point here is that DShell isn't magic. You can just write normal dart code using all of darts features and any libraries that work with a cli application. (i.e. flutter and web specific libraries are not going to work here.)

## Using dshell create
DShell likes to make life easier so if you can't remember the syntax of of main you can use:

```
dshell create hello_world.dart'
```
DShell will create the hello_world.dart script and peform the initial house keeping.
Your script is now ready to run.

NOTE: DShell will shortly introduce templates that will provide a collection of common scripts that you can use as a starting point.

## Our first real script

So let's do something that DShell was designed for, file management.

Create a new script `first.dart`

Copy the following contents to the script:

```dart
/// import DShell's global functions 
import 'package:dshell/dshell.dart';

void main() {
    print('Now lets do someting useful.');

    // create a directory
    createDir('tmp');
    
    // Lets write some text to a file.
    // DShell uses dart 2.6 extensions.
    // Ths allows us to extend [String] with
    // functions like [write] and [append]
    // [write] and [append] treat the contents
    // of the [String] as a filename.
    
    // Truncate any existing content
    // of the file 'tmp/text.txt' and write
    // 'Hello world' to the file.
    'tmp/text.txt'.write('Hello world');

    // append 'My second line' to the file 'tmp/text.txt'.
    'tmp/text.txt'.append('My second line');

    // and another append to the same file.
    'tmp/text.txt'.append('My third line');

    // now copy the file tmp/text.txt to second.txt
    copy('tmp/text.txt', 'tmp/second.txt');
    
    // lets dump the file we just created to the console
    cat('tmp/second.txt').forEach((line) => print(line));

    // lets prove that both files exist by running
    // a recusive find.
    find('*.txt').forEach((file) => print('Found $file'));

    // Now lets tail the file using the OS tail command.
    // Again using dart 2.6 extensions we treat a string
    // as an OS command and run that command as 
    // a child process
    // Any stdout and stderr output is written
    // directly to the console
    'tail tmp/text.txt'.run

    // Lets do a word count but capture stdout
    // stderr will still be written to the console
    'wc tmp.second.txt'.forEach((line) => print('Captured $line'));

    // lets tail a non existent file and see stderr.
    // The forEach method signagure is
    // forEach(LineAction stdout, {LineAction stderr})
    'tail tmp/nonexistant.txt'
            .forEach((line) => print('stdout: $line')
                , stderr: (line) => print('stderr: $line'));

    String result = ask(prompt: "Should I delete 'tmp'? (y/n):");

    if (result == 'y') {
        // Now lets clean up
        delete('tmp/text.txt');
        delete('tmp/second.txt');
        deleteDir('tmp');
    }

}

```

Now run our first script.

```
cli> dshell first.dart
Hello world
My second line'
My third line
Should I delete 'tmp'? (y/n):

```
You are now officially a DShell guru. 

Go forth you man (or gal) and create.


# DShell clean
If you change the structue of your DShell script project then you need to run `dshell clean` so that DShell sees the changes you have made.

What constitutes a structural changes?
* adding an `@pubspec` annotation to your DShell script
* creating a `pubspec.yaml` file in your scripts directory.
* creating a `lib` directory in your scripts directory.
* editing an existing `pubspec.yaml`
* editing an existing `@pubspec` annotation

What doesn't constitue a structural change?
* editing your DShell script

If you make a structure change simply call

```
dshell clean <scriptname>
```

Your script is now ready to run.


## DShell and futures
You will note in all of the above examples that there are no calls to `await` nor any usage of `Futures`.

This is very intentional.

DShell does not stop you using `await`, `Futures`, `Isolates` or any other dart functionallity. Its all yours to use and abuse as you will.

DShells global functions however intentially avoid `Futures`.

They aim of DShell is to create a bash like simplicity to system maintenance.  `Futures` are great and all but the do make the code more complex and harder to read.

Futures also can make your scripts a little dangerous. If you copy a file and then want to append to the copy, you had better be certain that the copy command has completed before you start the append.  DShell's global functions remove those complications.

If you are interested in how we avoid using `Futures` read up on `waitFor` and check out DShell's own `waitForEx` function that does stacktrace repair when an exception is thrown.



# Using DShell functions
Lets start by looking at the some of the built in functions that DShell supports. 

DShell exposes a range of built-in functions which are dart global functions.

These functions are the core of how DShell provides a very bash like feel to writing DShell scripts.

These functions make strong use of named arguments with intelligent defaults so mostly you can use the minimal form of the function.

Take note, there are no `Futures` or `await`s here. Each function runs synchronously.

Note: the file starts with a shebang which allows this script to be 
run directly from the cli (no precompilation required).
```dart
#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';

void main() {
    Settings().debug_on = true;

    // Print the current working directory
    print("PWD: ${pwd}");

    // Change to the directory 'main' 
    // NOTE: this is NOT best pratice use paths 
    // to each file instead.
    cd("main");

    // Create a directory and if necessary
    // its parent directories.
    createDir("tools/images", recursive: true);

    // Push the current directory onto the stack
    // and change directory to 'main/tools/images'
    push("tools/images");

    // create a file (its empty)
    touch("good.jpg", create: true);

    // update the last modified time on an existing file
    touch("good.jpg");

    // I think you know this one.
    // print works just as well.
    echo("All files");

    // print out all files in the current directory.
    // [file] is just a [String]
    find("*.*", recursive=false).forEach((file) => print(file));

    // take a nap for a couple of seconds.
    sleep(2);

    echo("Find file matching *.jpg");
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find("*.jpg").toList()) {
        print(file);
    }

    // Move/rename a file
    move("good.jpg", "bad.jpg");

    // check if a file exists.
    if (exists("bad.jpg")) {
        print("bad.jpg exists");
    }

    // Delete a file asking the user first.
    delete("bad.jpg", ask: true);

    // return to the directory we were in
    // before we called push above.
    pop();
  
    // Print out our current working directory.
    // should be main.
    echo(pwd);
}
```

As you can see we have achieved much of the power of Bash without any of the ugly grammar, and what's more we only used one type of quote!

DShell is the kind of friend that you actually introduce Grandma to.

# Running a script

DShell is intended to start as fast as bash and run faster than bash. 

When you first run your new DShell script, DShell has some house keeping todo including running a `pub get`. After the first run DShell will only run `pub get` if you call `dshell clean <scriptname.dart>`.

The result is that dshell has similar start times to bash and when running larger scripts is faster than bash.

If you absolutely need to make your script perform to the max, you will want to use the DShell `dshell compile <scriptname.dart>` command to compile your script to native code.

DShell provide three ways of running a script.

* use 'dshell' directly
* add a shebang
* compile to native.

The first time you run your DShell script using either of the first two options it needs to fetch any dependancies using `pub get`. This happens automatically. 

## Use DShell directly
The simplest way to run your DShell script is to directly use the `dshell` app.

Copy the following contents to a script and save it as `hello.dart`.

```dart
void main() {
    print('hello world');
}
```
Now run it.

```
dshell hello.dart
```

Running the script using `dshell` means you can create your script using your favorite editor and then immediately run it with `dshell`.

## Use a shebang

Once DShell is [installed](#Installing), you can run a DShell script just as you do with any bash script.

To do this add a shebang at the top of the script:

(Note: it must be the very first line!)

```dart 
#! /usr/bin/env dshell
void main() {
    print('hello world');
}
```

Save the file to something like: `tryme.dart`

Mark the file as executable:

```bash
chmod +x  tryme.dart
```

Note: if you used the `dshell create <script>` command then dshell will have already set the execute permission on your script.

Now run the script from the cli:

```bash
cli> ./tryme.dart
hello world
cli>
```

You're now offically in the land of DShell magic.

If you add your script directory to your path then you can run the script from anywhere.

```
cli>export PATH=~/scriptdir:${PATH}
cli>tryme.dart
hello world
cli>
```

## Compiling to Native
DShell also allows you to compile your script to a native executable.

```
dshell compile <scriptname.dart> -o exename
```

The `-o` option is optional. If not specified the exec will be called `<scriptname>` without the dart extension.

The `-o` option also allows a path to be specified so you can install the exe directly into a directory such as `/usr/bin`.

Run you natively compiled script to see just how much faster it is now:
```
./scriptname
```

As this is fully compiled, changes to your local script file will not affect it (until you recompile) and when the exe runs it will never need to do a pub get as all dependencies are built in.



You can also copy the exe to another machine (that is binary compatible) and run the exe without having to install dart.


# Calling cli applications

DShell can call any console application.

DShell does the nasty with the String class using Dart's (2.6+) 'extension' feature.
The aim of this somewhat unorthodox approach is to deliver the elegance that Bash achieves when
calling cli applications.

To achieve this we add a number of methods and operator overloads to the String class.

These include:
* run
* forEach(LineAction stdout, {LineAction stdout})
* toList()
* | operator

This is the resulting syntax:

```dart
    // run wc (word count) on a file
    // all wc output goes directly to the console
    'wc fred.text'.run

    // run grep, printing out each line but suppressing stderr
    'grep import *.dart'.forEach((line) => echo(line)) ;

    // run tail printing out stdout and stderr
    'tail fred.txt'.forEach((line) => echo(line)
        , stderr: (line) => print(line)) ;

```


# Piping

Now let's pipe the output of one cli command to another.

```dart

    'grep import *.dart' | 'head 5'.forEach((line) => print(line)) ;

```

The above command launches 'grep' and 'head' to find all import lines in any dart files and then trim the list (via head) to the first five lines and finally print those lines.

What we have now is the power of Bash and the elegance of Dart.


# Pubspec Management
DShell aims to make creating a script as simple as possible and with that in mind we 
provide a number of ways of creating and managing your pubspec.yaml.

By default you do NOT need a pubspec.yaml when using DShell.

NOTE: if you change the structure of your DShell script you need to run a `dshell clean`. Simple edits to you DShell script do NOT require a `clean` to be run.

## Default pubsec

If DShell doesn't find a pubspec then it will automatically create a default pubspec for you.
The default pubspec is stored in the script's Virtual Project cache (under `~/.dshell/cache/<path_to_script>.project`).

We refer to this as a 'virtual pubspec'.

When you first launch your script and after calling `dshell clean <scriptname.dart>` DShell creates/recreates your virtual pubspec.

Whether you use a virtual pubspec or create your own, DShell performs dependancy injection ([see dependancy injection](#Pubspec-dependancy-injection)) providing a common set of packages that together create a 'swiss army knife' of useful tools to use when developing DShell scripts.

## Explicitly defining a pubspec

If you find that you need additional dependencies or other controls that an explict pubspec provides, then you may
need to create your own pubspec.

DShell provides two ways to do this.

* an inline pubspec using DShell's `@pubspec` annotation.
* a classic dart pubspec.yaml with all the normal features.

The DShell `@pubspec` annotation allows you to retain the concept of a single script so you can copy your DShell script
anywhere and it will just work. 

Using the `@pubspec` annotation also means that you can have many DShell scripts living in the same directory each with their
own pubspec. If you use a classic pubspec.yaml then all your scripts will be sharing the same pubspec (which isn't necessarily a bad thing).

See the section on [PubSpec Precedence](#Pubspec-Precendence) for details on how DShell works if you mix pubspec annotations and a pubspec.yaml in the same directory.


For simple scripts you will normally use the `@pubspec` annotation but as your script grows you may want to migrate
to a separate `pubspec.yaml`. 

DShell has a tool to make this easier.

Run:
```
dshell split <scriptname.dart>
```

If your script `<scriptname.dart>` contains a `@pubspec` annotation then DShell will remove it from your script and create a classic `pubspec.yaml` file in the directory along side your script.


## Pubspec dependancy injection
When DShell creates your virtual pubspec, on first run or after a clean,it will inject a default set of dependancies into your pubspec.

It doesn't matter if you have relied on a virtual pubspec, used an `@pubspec` annotation or created a classic `pubspec.yaml` DShell always injects the following dependencies.

The default dependancies are:

* dshell
* [path](https://pub.dev/packages/path)
* [args](https://pub.dev/packages/args)

The above packages provide your script with a swiss army collection of tools that we think will make your life easier when writing DShell scripts.
The 'path' package provide tooling for building and manipulating directory paths as strings.
The 'args' package makes it easy to process command line arguments including adding flags and options to your DShell script.

To ensure that you still have complete control over your dependencies, DShell allows you to override the
default dependencies.

If you have declared any of the above packages in the dependancies section of you `@pubspec` annotation or your classic `pubspec.yaml` then the version you declare will be used and the dependency injection for that package will be suppressed.

## Customising dependancy injection

DShell provides a nice set of basic tools (packages) for your DShell scripts and you can add more in your script's pubspec. 

You may however find a really nice package that you use time and again in your DShell scripts which means you have to create a pubsec for every script.

DShell allows you to define your own set of global package dependancies that DShell will then inject into every DShell script.

If you create a `dependancies.yaml` file in the `~/.dshell` directory then DShell will inject any custom dependancies into your DShell scripts.


The syntax of `dependancies.yaml` is identially to the standard `pubspec.yaml` dependancies section.

Example:
```yaml

dependencies:
  collection: ^1.14.12
  file_utils: ^0.1.3
  money2: ^1.8.0

```

You don't need to specify the packages that DShell normally injects unless you want to override the version of the package that DShell injects.

NOTE: you must run 'dshell cleanall' if you modify your 'dependancies.yaml' as DShell doesn't check this file for changes.



## Pubspec Precendence
DShell allows you to define your pubspec either via a `@pubspec` annotation within your script or a classic
`pubspec.yaml` which lives in the same directory as your script.

DShell also support the concept of allowing multiple single file DShell scripts to exist
in the same directory.

This has the potential to create ambiguities as to which pubspec definition is to be used.

To remove the ambiguities these pubspec rules are used and applied in the following order:
1) If the script contains an `@pubspec` annotation use it.
2) If the scripts directory contains a `pubspec.yaml` use it.
3) If 1) and 2) fail then create a default virtual pubspec definition.

So what happens if you have multiple DShell scripts in a single directory and a classic pubspec.yaml file?
```
cli> ls
hello_world.art
find_me.dart
pubsec.yaml
cli>
```

Well according to the rules, if a DShell script has an `@pubspec` annotation then that will be used and the classic `pubspec.yaml` file will be ignored.

If your DShell script doesn't have an `@pubspec` annotation then the `pubspec.yaml` file will be used.

This means that multiple DShell scripts can share the same `pubspec.yaml` which could be convenient at times.

So a word of caution.

If you have an existing DShell script which relies on DShell's 'virtual pubpsec' (i.e. it doesn't have an `@pubspec` annotation) and you copy the script into a directory that has an existing `pubspec.yaml` then the next time you run your script from its new home it will use the adjacent `pubspec.yaml`.


## @pubspec Annotation

The `@pubspec` annotation allows you to specify your pubspec defintion right inside your DShell script.

Using an `@pubspec` annotation allows you to retain the concept of a single independant script file.
This has the advanage that you can copy your DShell script file anywhere and just run it (provided DShell is installed).

To add a `@pubspec` annotation to your file add the `@pubspec` annotation within a `/*  */` comment and follow the standard
rules for formatting a `pubspec.yaml` file.

Remember, yaml is fussy about the right level of indentation!


```dart
#! /usr/bin/env dshell

/*
@pubspec.yaml
name: tryme
dependencies:
  money2: ^1.0.3
*/

import 'package:dshell/dshell.dart';
import 'package:money2/money2.dart';

void main()
{
    Currency aud = Currency.create("AUD", 2);
    Money notMuch = Money.parse("\$2.50", aud);

    echo("Hello World");
    echo("All I have is ${notMuch}");
}
```

If your `@pubspec` annotation gets large, you might want to split the annotation out to a classic `pubspec.yaml` file.
To do this you can use the DShell split command.

```
dshell split <script filename>
```

Once the `split` command completes you will have a newly created `pubspec.yaml` file and you `@pubspec` annotation will have been removed from your script.

## Multi-file scripts

As with all little projects they have a habit of getting larger than expected.
At some point you are going to want to spread you script over multiple dart libraries.

Well, DShell supports this as well.

If you need to create additional libraries (.dart files) create a subdirectory called 'lib', which shouldn't be too much of a surprise.


Place the following file in:
    
    ~/myproject/tryme.dart

```dart

#! /usr/bin/env dshell

/*
@pubspec.yaml
name: tryme
dependencies:
  money2: ^1.0.3
*/

import 'package:dshell/dshell.dart';
import 'package:money2/money2.dart';

// import a local library
// tax.dart must be in a subdirectory called 'lib'.
import 'package:tryme/tax.dart';

main()
{
    Currency aud = Currency.create("AUD", 2);
    Money notMuch = Money.parse("\$2.50", aud);

    echo("Hello World");
    echo("All I have is ${notMuch}");

    echo("And the taxman takes: ${tax(notMuch)});
}

```

Place the library file in:

    ~/myproject/lib/tax.dart
```dart

    Money tax(Money amount)
    {
        return amount * 0.1;
    }
}

```

Run you script the same way as usual:

```
    dshell tryme.dart
```

# DShell commands
DShell provides a number of command line tools to help you manage your DShell scripts.
All of the tools are commands passed to the `dshell` application.

You can see a full list of `dshell` commands and arguments by running:
```
dshell 
dshell help
dshell help <command>
```


The syntax of `dshell` is: 

```
dshell [flag, flag...] [command] [arguments...]
```

## flags
DShell supports a verbose flag: `--verbose | -v`

When passed to dshell it will result in additional logging being written to the cli (stdout).


## cleanall
The clean all command will delete all of the Virtual Projects under `~/.dshell/cache and rebuild each of them.

Usage: `dshell cleanall`

Example:

```
dshell cleanall
```

## clean
The clean command will rebuild the Virtual Project for a single DShell script.

Usage: `dshell clean <script path.dart>`

Example: 

```
dshell clean hello_world.dart
```

## compile
The compile command will compile your DShell script into a native executuable.

The resulting native application can be copied to any binary compatible OS and run without requiring dart to be installed.

Dart complied appliations are also super fast.

Usage: `dshell compile <script path.dart>`

Example: 

```
dshell compile hello_world.dart

./hello_world
```

## create
The create command create a sample DShell script using the given script file name and initialise your project by running `dshell clean`.

Usage: `dshell create <script path.dart>`

Example: 

```
dshell create my_script.dart
```


## run
Runs the given DShell script.

This command is NOT required. 

The recommended way to run a dshell script is via one of the documented [run methods](#Running-a-script).

The `dshell run` command is provided for symmetry and the possiblity that someone, someday, may try to auto generate calls to dshell and having a consistent command structure can make this easier.

Usage: `dshell run <script path.dart>`

Example: 

```
dshell run my_script.dart
```

## split
The split command extracts a `@pubspec` annotation from a DShell script and writes it to a `pubslec.yaml` file in the same directory as the script.

This is a convenience method as you can perform the same process manually.

Usage: `dshell split <script path.dart>`

Example: 

```
dshell split my_script.dart
```


# Internal workings
For those of interest this section covers off how the internals of DShell function.

## Virtual Projects
A normal Dart program requires a certain directory structure to work:
```
hello_world.dart
pubspec.yaml
lib/util.dart
```

The aim of DShell is to remove the normal requirements so we can run a single dart script while still allowing you to gracefully grow your little project to a full blow application without having to start over.

Virtual Projects are where this magic happens.

DShell creates a configuration directory in you home directory:
```
~/.dshell
~/.dshell/templates
~/.dshell/dependancies.yaml
~/.dshell/cache
```

When you run a DShell script, DShell creates a Virtual Project under the `cache` directory using the fully qualified path to you script.

So if you have a script:
```
/home/fred/myscripts/hello_world.dart
```

then DShell will create a Virtual Project under the path

```
~/.dshell/cache/home/fred/myscripts/hello_world.project
```

Using the fully qualified path allows multiple scripts to exist in the same directory and we can still run a Virtual Project for each script.

Within the Virtual Project directory DShell creates all the necessary files and directories need to make dart happy

So a typical Virtual Project will contain:

```
symlink -> hello_world.dart
pubspec.yaml
```

The pubspec.yaml is referred to as your `virtual pubspec` and is created as per the [pubspec precendence](#Pubspec-Precendence) rules and the [dependency injection](#Pubspec-dependancy-injection) rules.

If you script directory contains a `lib` folder then we create:

```
symlink -> /home/fred/myscripts/hello_world.dart
pubspec.yaml
symlink -> /home/fred/myscripts/lib
```

The first  time you run a DShell script and when you perform a `dshell clean` DShell recreates your pubspec.yaml, rebuilds your Virtual Project and runs `pub get`.

## waitFoEx
DShell goes to great lengths to remove the need to use `Futures` and `await` there are two key tools we use for this.

`waitFor` and `streams`.

`waitFor` is a fairly new dart function which ONLY works for dart cli applications and can be found in the `dart:cli` package.

`waitFor` allows a dart cli application to turn what would normally be an async method into a normal synchronious method by effectively absorbing a future.
Normally in dart, as soon as you have one async function, its async all of the way up.
DShell simply wouldn't have been possible without `waitFor`.

`waitFor` does however have a problem. If an exception gets thrown whilst in a `waitFor` call, then the stacktrace generated will be a microtask based stack trace. These stacktraces are useless as they don't show you where the original call came from.

This is why `waitForEx` was born. `waitForEx` is my own little creation that does three things. 
1. capture the current stack using StackTraceImpl
2. calls `waitFor` and catches any exceptions
3. If an exception is thrown it patches the stack trace captured in 1 and merges it with the interesting bits of the microtask exception.

The result is that you get a clean stacktrace that points to the exact line that cause the problem and we have a stacktrace that actually shows where it was called from.





# Contributing
Read the wiki on contributing to DShell

https://github.com/bsutton/dshell/wiki

# References

Projects I referenced (stole stuff from) when making this package:

https://pub.dev/packages/dscript_exec

https://pub.dev/packages/dartx

https://pub.dev/packages/completion
