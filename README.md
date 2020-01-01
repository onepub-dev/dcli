# DShell - a bash replacement using the Dart programming language

# Contents
* [Overview](#overview)
* [So why DShell](#so-why-dshell)
* [What does DShell do?](#what-does-dshell-do)
* [What commands does DShell support?](#what-commands-does-dshell-support)
* [Getting Started](#getting-started)
* [Installing](#installing)
* [Writing your first script](#writing-your-first-script)
  * [Our first real script](#our-first-real-script)
  * [Dart lambda functions](#dart-lambda-functions)
  * [Named Arguments](#named-arguments)
  * [Use a shebang](#use-a-shebang)
  * [DShell clean](#dShell-clean)
* [DShell and futures](#dshell-and-futures)
  * [Just ignore Futures](#just-ignore-Futures)
  * [How DShell manages futures](#how-dshell-manages-futures)
* [Using DShell functions](#using-dshell-functions)
* [Performance](#performance)
* [Compiling to Native](#compiling-to-native)
* [Calling cli applications](#calling-cli-applications)
* [Piping](#piping)
* [CD/Push/Pop are evil](#cdpushpop-are-evil)
  * [Why is cd dangerous?](#why-is-cd-dangerous)
* [Dependency Management](#dependency-management)
  * [Sharing packages](#sharing-packages)
* [Pubspec Management](#pubspec-management)
  * [Default pubsec](#default-pubsec)
  * [Explicitly defining a pubspec](#Explicitly-defining-a-pubspec)
  * [Pubspec dependancy injection](#pubspec-dependancy-injection)
  * [Overriding default dependancy](#overriding-default-dependancy)
  * [Pubspec precendence](#pubspec-precendence)
  * [@pubspec Annotation](#@pubspec-annotation)
* [Multi-file scripts](#multi-file-scripts)
* [DShell commands](#dshell-commands)
  * [flags](#flags)
  * [cleanall](#cleanall)
  * [clean](#clean)
  * [compile](#compile)
  * [create](#create)
  * [install](#install)
  * [run](#run)
  * [split](#split)
* [Upgrading DShell](#upgrading-dshell)
* [Internal workings](#Internal-workings)
  * [Virtual Projects](#virtual-projects)
  * [waitForEx](#waitForEx)
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

Bash is probably the most commonly used scripting tool for system maintenance.

Bash has been around for a long time and wasn't so much designed as evolved.

The problem now is that its old, has an archaic syntax and doesn't scale well.

So why is dshell different?

DShell is based on the relatively new programming language; Dart.

Dart is currently the fastest growing language on github and is the basis on which Flutter is built. If have not heard of flutter then you should have a look, but I digress.

If you have used multiple languages you well know how the learning curve goes. Its usually doesn't take long to the get to the point where you love or hate a language. 
As you begin to discover the little nooks and crannies of a language you either despise the designer's solutions or fall in love with it.

For me at least, it was love at first sight.

Dart is a simple to learn, and uses the all too familiar 'C' style syntax.

It provides elgant solutions for common problems and from a scripting perspective hits all of the high notes.

DShell excels in all of the functionality that you expect from Bash and then takes you to the next level.

DShell is easy to install, makes it a breeze to create simple scripts and provides the tools to manage a script that started out as 100 lines but somehow grew to 10,000 lines. There is also a large collection of third party libraries that you can included in your script with no more than an import statment and a dependancy declaration. 

Dart is fast and if you need even more speed it can be compiled to a single file executable that is portable between binary compatible machines.

You can use your favorite editor to create DShell scripts. Vi or VIM work fine but Visual Code is recommended. 

DShell and Dart also make it harder to make some of the common mistakes that Bash invites.

With Dart and DShell you have the option to Type your variables. This is a bit of a controversial issues so DShell doesn't force you to Type your scripts but I ALWAYS use types and you should too.

For a long time I've wanted to build a replacement tool that has the elegance of a modern language, with the power of Bash.

DShell is hopefully that.

## What does DShell do?

* Makes it easy to write maintenance scripts as you do with Bash. 
* Uses the elegant and simple Dart language
* Provides a set of functions (commands) that mimick common bash operations.
* Allows for simple manipulation of files and directories
  * move(from, to), createDir(path), cd(path)...
* Allows you to call any cli application in a single line
  * 'grep error /var/lib/syslog'.run
* Write and execute single file scripts
  * cli> ./tryme.dart
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

Lets install DShell, create and run our first script:

Start by installing Dart as per:

https://dart.dev/get-dart


Once Dart is installed we can install DShell.

```shell
pub global activate dshell
dshell install
```

Now lets create and run our first DShell script.

To create a script we can use the `dshell create` command.

e.g. 
```bash
dshell create test.dart
```

As part of the creation process we need to fetch the set of dependencies for your script.
The step 'Resolving dependencies...' can take 20 or 30 seconds to run.

This is a once off process for each script.

```
cli> mkdir dtest
cli> cd dtest

cli> dshell create test.dart
Creating project.
Created Virtual Project at /home/bsutton/.dshell/cache/tmp/test.project
Running pub get...
Resolving dependencies...
+ args 1.5.2
+ charcode 1.1.2
+ collection 1.14.12
+ dshell 1.0.23
+ equatable 1.0.1
+ file 5.1.0
+ file_utils 0.1.3
+ globbing 0.3.0
+ intl 0.16.0
+ logger 0.8.1
+ matcher 0.12.6
+ meta 1.1.8
+ money2 1.3.0
+ path 1.6.4
+ pub_semver 1.4.2
+ pubspec 0.1.2
+ quiver 2.1.2+1
+ recase 2.0.1
+ source_span 1.5.5
+ stack_trace 1.9.3
+ string_scanner 1.0.5
+ stuff 0.1.0
+ term_glyph 1.1.0
+ uri 0.11.3+1
+ utf 0.9.0+5
+ yaml 2.2.0
Downloading dshell 1.0.23...
Changed 26 dependencies!
Precompiling executables...
Precompiled dshell:dshell.
Making script executable
Project creation complete.

To run your script:
  dshell test.dart
cli>
```

The `dshell create test.dart` command creates a basic hello world script.

If you `cat`/`type` the contents you should see:

```
#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
  print("Hello World");
}
```

Note: the 'Hello World' text may differ ;)

You can now run you script:

```bash
cli>dshell test.dart
Hello World
```

Note for Flutter users:

I had a problem with my installation where the flutter internal verion of the dart-sdk was
on my path before the os version. I don't believe the flutter dart-sdk should be on your path.
Removing it from my path allowed me to developed cli apps as well as flutter.

## Writing your first script

In the Installing section we used the `dshell create` command to create a simple DShell script, but to show there isn't any magic lets create one from scratch.

Let's start with the classic hello_world.dart

```shell
mkdir hellow
cd hellow
```

Create a file called `hello_world.dart`.

Copy the following contents to the script.

```dart
void main() {
    print('hello world');
}
```

Now run the script.
You may see a few extra lines after 'Resolving dependancies...' as DShell downloads and caches any required libraries.

```
cli> dshell hello_world.dart
Resolving dependancies...
...
hello world
cli>
```

So that was simple.


The first time you run a given DShell script, DShell needs to resolve any dependancies by running a Dart `pub get` command and doing some other house keeping.

If you run the same script a second time DShell has already resolved the dependancies and so it can run the script immediately.


```
cli>dshell hello_world.dart
hello world
cli>
```


> In the Dart world a `.dart` file is referred to as a 'library'. As you will see a Dart library can contain global functions and multiple Dart classes.

So far this is just a normal dart library that you can run directly from the command line.

The point here is that DShell isn't magic. You can just write normal Dart code using all of Dart's features and any libraries that work with a cli application. (i.e. flutter and web specific libraries are NOT going to work here.)

## Our first real script

So let's do something that DShell was designed for; file management.

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
    // functions like [write] and [append].
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
    // a recursive find.
    find('*.txt').forEach((file) => print('Found $file'));

    // Now lets tail the file using the OS tail command.
    // Again using dart 2.6 extensions we treat a string
    // as an OS command and run that command as 
    // a child process
    // Any stdout and stderr output is written
    // directly to the console
    'tail tmp/text.txt'.run

    // Lets do a word count capturing stdout,
    // stderr will will be swallowed.
    'wc tmp.second.txt'.forEach((line) => print('Captured $line'));

    // lets tail a non existent file and see stderr.
    // The forEach method signature is
    // forEach(LineAction stdout, {LineAction stderr})
    // The curly braces make [stderr] a 'named' parameter
    // whilst [stdout] is a a positional parameter.
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

Now run our script.

```
cli> dshell first.dart
Hello world
My second line
My third line
Should I delete 'tmp'? (y/n):

```
You are now officially a DShell guru. 

Go forth young man (or gal) and create.

# Dart lambda functions
This section provides details on the Dart language:

To learn more about Dart's syntax read the Dart language tour.
https://dart.dev/guides/language/language-tour


DShell makes extensive use of Dart's lambdas.  

Lambdas are essentially annonymous functions which DShell uses for callbacks.

The most common use of lambdas in DShell are in the forEach method.

In prior examples you have already seen the forEach method in action.

```dart
'tail tmp/nonexistant.txt'.forEach((line) => print(line));
```

The signature of the forEach method is:

```dart
void forEach(LineAction stdout, {LineAction stderr});
```

The first argument `stdout` of the forEach method is a 'positional' argument, the second argument `stderr` is a named argument.
The `stdout` argument is required whilst the `stderr` argument is optional.

`LineAction` is a Dart `typedef` that declares that LineAction is a function that takes a single String.

`typedef LineAction = void Function(String line);`

Essentially this means that forEach expects you to pass a function to the first positional argument `stdout` and optionally the second argument `stderr`.

The functions that you pass are unnamed functions known as a Lambda.

The following code uses the [stdout] positional argument to print each line returned by the call to the Linux 'tail' command.

```dart
'tail tmp/nonexistant.txt'.forEach(
    (line) => print(line)
    );
```

The 2nd line is the Lambda function that you provide.

Lets break this down.

The line consists of three components

`(line) => print(line)`

Which can be abstracted to:

`(<args>) => <expression>`

In our example the `stdout` positional argument is of type `LineAction`.  The `LineAction` function takes a String as its only argument.
So in this case `(<args>)` is a single argument of type String.

What this means is that the `forEach` method will call the Lambda function each time the `tail` command outputs a line. The value of that line will be contained in the `line` argument passed to your Lambda.

The second component is the `=>` operator, sometimes refered to as a 'fat arrow'. Essentially the `=>` operator passes the `line` argument to the `<expression>`;

The third and final component is the `<expression>`.

The `<expression>` can be any valid Dart expression. In the above example the expression is `print(line)` which prints the contents of `line` to the console.

One limitation of the `<expression>` is that it must be a single line expression. Our `LineAction` is declared as returning a void so in our case the value of the expression is ignored.

Dart's Lambdas actually take two forms the above 'fat arrow' form and a 'block form'.

The block form allows you to execute multiple statements and requires you to use a `return` statement if you want to return something from the Lambda.

The syntax of the Lambda block form is:

`(args) { <statements> }`

Look carefully and note that the block form doesn't have the 'fat arrow'. I've often been caught when converting a 'fat arrow' form to the block form leaving the 'fat arrow' in place and that just doesn't work.

Block form example of a Lambda:

```dart
'tail tmp/nonexistant.txt'.forEach(
    (line) {
         String trimmed = line.trim();
         print(trimmed);

         // If LineAction took a non-void return type then we could use 
         // a return statement here
         // return 'some value';
    }
);
```

Have a look a the next section of named arguments to understand how to process `stderr` when interacting with the `forEach` method.

# Named Arguments

This section provides details on the Dart language:

To learn more about Dart's syntax read the Dart language tour.
https://dart.dev/guides/language/language-tour

Dart allows three types of arguments to be passed to a method or function.

Positional, optional and named.

Positional arguments are traditional 'C' style arguments that everyone is familiar with.

Optional arguments are positional arguments that are (you guessed it) optional.

Named arguments are a little tricker but depending on your current language experience you may already be familiar with them.

Named arguments allow you to pass an argument by name rather than position and they are optional.

To declare a positional argument you use curly braces `{}`.

```dart
testMethod(String arg1, [String arg2], {String arg3, String arg4});
```

In the above example `arg1` is a positional argument, `arg2` is an optional argument with `arg3` and `arg4` being named arguments.

To call the test method passing values to all of the above arguments you would use:

```dart
testMethod('value1', 'value2' , arg4: 'value4', arg3: 'value3');
```

Note that I've reversed the order of `arg3` and `arg4`. As they are named arguments you can place them in an position AFTER the named and optional arguments.

Lets finish with an example using the forEach method:

```dart

'tail /var/log/syslog'.forEach((line) => print(line), stderr:(line) => print(line));
```

The above example will print any output sent to stdout or stderr from the 'tail' command.



## Use a shebang

DShell also allows you to directly run a script. 
e.g.
```shell
./first.dart
```


To do this add a shebang at the top of the script:

(Note: it must be the very first line!)

```dart 
#! /usr/bin/env dshell

/// import DShell's global functions 
import 'package:dshell/dshell.dart';

void main() {
```

Save the file.

Now mark the file as executable:

```bash
chmod +x  first.dart
```

Note: if you used the `dshell create <script>` command then DShell will have already set the execute permission on your script and added the shebang!

Now run the script from the cli:

```bash
cli> ./first.dart
Hello world
My second line
My third line
Should I delete 'tmp'? (y/n):
cli>
```

You're now offically in the land of DShell magic.

If you add your script directory to your path then you can run the script from anywhere.

```
cli>export PATH=~/scriptdir:${PATH}
cli>first.dart
Hello world
My second line
My third line
Should I delete 'tmp'? (y/n):
cli>
```

Faster you say? 

Read the section on [compiling](#compiling-to-native) your script to make it run even faster.


## DShell clean
If you change the structue of your DShell script project then you need to run `dshell clean` so that DShell sees the changes you have made.

What constitutes a structural changes?
* adding an `@pubspec` annotation to your DShell script
* creating a `pubspec.yaml` file in your scripts directory.
* creating a `lib` directory in your script's directory.
* editing an existing `pubspec.yaml`
* editing an existing `@pubspec` annotation

What doesn't constitue a structural change?
* editing your DShell script

If you make a structure change simply call

```
dshell clean <scriptname.dart>
```

Your script is now ready to run.


# DShell and futures
if your not a Dart programmer (yet) one of the most difficult things about Dart are Futures. If you are familiar with Javascript then a Future is the equivalent of a Promise.

## Just ignore Futures
If your not familiar with Dart of Javascript then for the moment you can just ignore futures. 

DShell works very hard to ensure that you don't need to worry about Futures.

This is very intentional.

If you stick to using DShell's built in functions then you can completely ignore Futures. If you start importing Dart's core libraries or third party libraries then you need to pay attention to return types. 

The first time you try to call a method or function that returns a `Future` then its you will know its time to come back here and read about Futures.

Until then you can just skip this section.

## How DShell manages futures

DShell does not stop you using `await`, `Futures`, `Isolates` or any other Dart functionallity. Its all yours to use and abuse as you will.

DShells global functions however intentially avoid `Futures`.

They aim of DShell is to create a Bash like simplicity to system maintenance.  `Futures` are great and all but they do make the code more complex and harder to read.

Futures also can make your scripts a little dangerous. If you copy a file and then want to append to the copied file, you had better be certain that the copy command has completed before you start the append.  DShell's global functions remove those complications.


If you are interested in how we avoid using `Futures` read up on `waitFor` and check out DShell's own `waitForEx` function that does stacktrace repair when an exception is thrown.

When you need to use futures you can read up on them in the Dart language Tour:

https://dart.dev/guides/language/language-tour

# Using DShell functions
Lets start by looking at the some of the built in functions that DShell supports. 

DShell exposes a range of built-in functions which are Dart global functions.

These functions are the core of how DShell provides a very Bash like feel to writing DShell scripts.

These functions make strong use of named arguments with intelligent defaults so mostly you can use the minimal form of the function.

Take note, there are no `Futures` or `await`s here. Each function runs synchronously.

Note: the file starts with a shebang which allows this script to be 
run directly from the cli (no precompilation required).
```dart
#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';

void main() {
    // Use the global DShell Settings to enable debug output.
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


# Performance

DShell is intended to start as fast as Bash and run faster than Bash. 

When you first run your new DShell script, DShell has some house keeping to do including running a `pub get` which retrieves and caches any of your scripts dependancies. After the first run DShell will only run `pub get` if you call `dshell clean <scriptname.dart>`.

The result is that DShell has similar start times to Bash and when running larger scripts is faster than Bash.

If you absolutely need to make your script perform to the max, you will want to use DShell to compile your script

## Compiling to Native
DShell also allows you to compile your script and any dependencies to a native executable.

```
dshell compile <scriptname.dart> -o exename
```

The `-o` option is optional. If not specified the resulting executable will be called `<scriptname>` without the `.dart` extension.

The `-o` option also allows a path to be specified so you can install the executable directly into a directory such as `/usr/bin`.

DShell will automatically marke your new exec as executable using `chmod +x`. 

Run you natively compiled script to see just how much faster it is now:
```
./scriptname
```

As this is fully compiled, changes to your local script file will not affect it (until you recompile) and when the exe runs it will never need to do a pub get as all dependencies are compiled into the native executable.


You can now copy the exe to another machine (that is binary compatible) and run the exe without having to install Dart, DShell or any other dependancy.


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

The above command launches 'grep' and 'head' to find all import lines in any Dart file and then trim the list (via head) to the first five lines and finally print those lines.

What we have now is the power of Bash and the elegance of Dart.

# CD/Push/Pop are evil
The cd, pushd and popd commands of Bash seem like fun but they are actually harbingers of evil.

DShell supports CD, Push and Pop but I strongly recommend that you don't use them.

I know that they they are used everywhere and they seem such an elegant solution but in a script they just shouldn't be used.

Instead use relative or absolute paths.

DShell automatically injects the rather excelent package ['path'](https://pub.dev/packages/path)  which includes an array of global functions that allow you to build and manipulate file paths.

Such as: 
```dart
join('directory', 'file.txt');
```

With the `path` package at your disposal there is really no need to use cd, push or pop.

## Why is cd dangerous?

There are several reasons.

1) Dart is multi-threaded
>This probably won't be an issue for you as DShell will NEVER start an Isolate and most scripts don't need to use Isolates but best pratices says that you should assume that one day you might just need to use one, so read on...
>
>Dart and consequently DShell allow you to run multiple threads of execute via Isolates.
>
>The problem is that all of these Isolates running in your Dart process share a single common working directory (CWD or PWD).
>
>This means that if you use CD in one isolate, then all other isolates have their working directory changed under their feet.
>
>Imagine if you are about to do a recusive delete in one isolate and some other Isolate changes the working directory to `/`. 
>
>Oops you just deleted your entire file system.

2) A function forgets to pop

>What happens if you call a function that happens to change the working directory?
>
>Again you can end up deleting your entire file system if the function changes to `/`.
>
3) Another process deletes your working directory
> What happens if another process deletes your working directory just as you are about to delete all of its contents?
> If you are using the 'paths' package then it will climb the path until it finds a directory that exist and set that as you new working directory. Your new working directory could well be the root directory.

The correct answer is simply don't use CD/PUSH/POP.

Use relative or absolute paths.

# Dependency Management
Dart has a large collection of built in packages. You can read about the core packages at:

https://dart.dev/guides/libraries/library-tour


However, sometimes you need a specialised package.

There are thousands of third party packages that you can use in your DShell scripts which can be found at:

https://pub.dev/packages

NOTE: you can't use Flutter packages in your DShell scripts.

To use an external package you need to add it as a dependency to your script.

Dart's dependency management is done via a pubspec.yaml file. However in most cases you won't need to create a pubspec.yaml file.

See the section on [Pubspec Management](#pubspec-management) for details.

Each package includes install instructions which is simply a matter of adding a dependency line to your pubspec and running:

`dshell clean <script>`.

## Sharing packages
When building scripts you often developed common coding patterns and use a common set of packages to help get the job done.

DShell helps you manage these common packages by allowing you to define a set of Dart packages that are injected into every script you run.

See the section on [Customising Depenendency Injection](#customising-dependancy-injection) for details.


# Pubspec Management


The `pubspec.yaml` file is Dart's  equivalent of a `makefile`, `pom.xml`, `build.gradle` or `package.json`.

You can see additional details on Dart's pubspec here:

https://dart.dev/tools/pub/pubspec


DShell aims to make creating a script as simple as possible and with that in mind we provide a number of ways of creating and managing your pubspec.yaml.

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
* a classic Dart pubspec.yaml with all the normal features.

The DShell `@pubspec` annotation allows you to retain the concept of a single script so you can copy your DShell script
anywhere and it will just work. 

Using the `@pubspec` annotation also means that you can have many DShell scripts living in the same directory each with their
own pubspec. If you use a classic pubspec.yaml then all your scripts will be sharing the same pubspec (which isn't necessarily a bad thing).

See the section on [PubSpec precedence](#Pubspec-Precendence) for details on how DShell works if you mix pubspec annotations and a pubspec.yaml in the same directory.


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

It doesn't matter if you have relied on a virtual pubspec, used an `@pubspec` annotation or created a classic `pubspec.yaml` DShell always injects the default dependencies.

DShell stores the default dependencies in:

`~/.dshell/dependencies.yaml`


The syntax of `dependancies.yaml` is idential to the standard `pubspec.yaml` dependancies section.

Example:
```yaml

dependencies:
  dshell: ^1.0.0
  args: ^1.5.2
  path: ^1.6.4
```


If you find a really nice package that you use time and again then its easier to add it to the set of default dependencies than having to add it to every script.

Feel free to modify the set of dependencies that DShell ships with. The only one you really need is the Dshell package (but you can even remove that if you don't like the standard DShell library). 

The default dependancies are:

* dshell
* [path](https://pub.dev/packages/path)
* [args](https://pub.dev/packages/args)

The above packages provide your script with a swiss army collection of tools that we think will make your life easier when writing DShell scripts.

The 'path' package provide tooling for building and manipulating directory paths as strings.

The 'args' package makes it easy to process command line arguments including adding flags and options to your DShell script.


## Overriding default dependancy

DShell provides a nice set of basic tools (packages) for your DShell scripts and you can add more in your script's pubspec. 

Some times you may find that a script needs a specific version of a default dependency. DShell allows you override a default dependencies version on a per script basis.


If you have declared any of the default packages in the dependancies section of you `@pubspec` annotation or your classic `pubspec.yaml` then the version you declare will be used instead of the default version.


NOTE: you must run 'dshell cleanall' if you modify your 'dependancies.yaml' as DShell doesn't check this file for changes.


## Pubspec precendence
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

# Multi-file scripts

As with all little projects they have a habit of getting larger than expected.
At some point you are going to want to spread you script over multiple dart libraries.

Well, DShell supports this as well.

If you need to create additional libraries (.dart files) create a subdirectory called 'lib', which shouldn't be too much of a surprise for Dart programmers.


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

    // Call the 'tax' function which is in 
    // lib/tax.dart
    echo("And the taxman takes: ${tax(notMuch)});
}

```

Now create the library file as:

    ~/myproject/lib/tax.dart

And copy the following contents into tax.dart.

```dart

    Money tax(Money amount)
    {
        return amount * 0.1;
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

The resulting native application can be copied to any binary compatible OS and run without requiring Dart to be installed.

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

## install
The install command has two forms.
      
```dart
dshell install
```
Completes the installation of dshell. See the section on (Installing DShell)[#Installing] for details.


NOTE: The following variation is not implemented as yet.

The alternate form 

```dart
dshell install <scriptname>
```

compiles the given script to a native executable and installs the script to your path. 

You only need to use the 'install' or 'complie' commands if you want super fast execution.


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

# Upgrading DShell
When a new version of DShell is released you will want to upgrade to the latest version.

We run the same process as we did when installing DShell to upgraded it.

```shell
pub global activate dshell
dshell install
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

The aim of DShell is to remove the normal requirements so we can run a single Dart script while still allowing you to gracefully grow your little project to a full blow application without having to start over.

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

Within the Virtual Project directory DShell creates all the necessary files and directories need to make Dart happy

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

## waitForEx
DShell goes to great lengths to remove the need to use `Futures` and `await` there are two key tools we use for this.

`waitFor` and `streams`.

`waitFor` is a fairly new Dart function which ONLY works for Dart cli applications and can be found in the `dart:cli` package.

`waitFor` allows a Dart cli application to turn what would normally be an async method into a normal synchronious method by effectively absorbing a future.
Normally in Dart, as soon as you have one async function, its async all of the way up.
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
