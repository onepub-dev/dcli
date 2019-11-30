# DShell - a bash replacement using dart

# Contents
* [Overview](#Overview)
* [So why DShell](#So-why-DShell?)
* [What does Dshell do?](#What-does-Dshell-do?)
* [What commands does Dshell support?](#What-commands-does-Dshell-support?)
* [Using Dshell functions](#Using-Dshell-functions)
* [Running a script](#running-a-script)
* [Calling cli applications](#Calling-cli-applications)
* [Piping](#Piping)
* [Installing](#Installing)
* [Running scripts](#Running-scripts)
* [External packages](##External-packages)
* [Multi-file scripts](#Multi-file-scripts)
* [Compiling to Native Executable](#Compiling-to-Native-Executable)
* [Contributing](#Contributing)
* [References](#References)

# Overview

DShell is intended to provide a replacement for bash and similar shell scripting languages with a Dart based scripting tool.

Bash has been the 'go to tool' for scripting file system operations for decades and it provides a wealth 
of really useful features.

Bash exemplifies the unix philosophy of Lego. The building of small, simple, re-usable blocks (applications) that can be coupled together to solve complex problems.

Bashes power lies in its ability to chain multiple commands together to provide a quick (and often dirty) solution.

Bash has an elegant set of commands for common file operations such as mv, cp, rm etc.

## So why DShell?

Whilst Bash is a powerful tool, it has a grammar that would make your Grandma blush.

**It useage of quotes can only be described as..., oh wait, it so complex it's indescribable.**

For a long time I've wanted to build a replacement tool that has the elegance of a modern language, with the power of bash.

DShell is hopefully that.

## What does Dshell do?

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

## What commands does Dshell support?

DShell ships with a number of built in functions and the abilty to call any cli application and easily process the output.

These are some of the built-in commands:
* move( from, to)
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
See the section below on [installing](#Installing) dshell.

Lets start with the simpliest of scripts, hello_world.dart

Create a file called `hello_world.dart`.

Copy the following contents to the script.

```dart
void main() {
    print('hello world');
}
```

Now lets run the script.

```
dshell hello_world.dart

cli> hello world
```

So far this is just a normal dart library and in fact you don't really need dshell to run the above script as the dart cli command can do the same thing. 
So lets do some dshell magic.

Create a new script `first.dart`

Copy the following contents to the script:

```dart

import 'package:dshell/dshell.dart';

void main() {
    print('Now lets do someting useful.');

    // create a directory
    createDir('tmp');
    
    // Lets write some text to a file.
    // We use dart 2.6 extensions so we can 
    // can treat a string that contains a file name
    // as a file and write or append to that file.
    
    // Truncate any existing file content and write
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

    // lets prove that both files exit by running
    // a recusive find.
    find('*.txt').forEach((file) => print('Found $file'));

    // Now lets tail the file using the OS tail command.
    // Again with the 2.6 extensions we treat a string
    // as OS command and run that command.
    // Any stdout and stderr output is written
    // directly to the console
    'tail tmp/text.txt'.run

    // Lets do a word count but capture sdtout
    'wc tmp.second.txt'.forEach((line) => print('Captured $line'));

    // lets tail a non existent file and see stderr
    'tail tmp/nonexistant.txt'
            .forEach((line) => print('stdout: $line')
                , stderr: (line) => print('stderr: $line'));

    // Now lets clean up
    delete('tmp/text.txt');
    delete('tmp/second.txt');
    deleteDir('tmp');

}

```

Now run our first script.

```
dshell first.dart

cli> 
'tmp/text.txt'.write('Hello world');
    'tmp/text.txt'.append('My second line');
    'tmp/text.txt'.append('My third line')
```




# Using Dshell functions
Lets start by looking at the some of the built in functions that DShell supports. 

The built-in functions are dart global functions providing a very bash like feel to writing dshell scripts.
The functions make strong use of named arguments with intelligent defaults so mostly you can use the minimal form of the function.

Take note, there are no Futures here. Each function runs synchronously.

Note: the file starts with a shebang which allows this script to be 
run directly from the cli (no precompilation required.)
```dart
#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';

void main() {
    Settings().debug_on = true;

    // Print the current working directory
    print("PWD: ${pwd}");

    // Change to the directory 'main'
    cd("main");

    // Create a directory with any needed parents.
    createDir("tools/images", createParent: true);

    // Push the current directory onto the stack
    // and change directory.
    push("tools/images");

    // create a file (its empty)
    touch("good.jpg", create: true);

    // update the last modified time on an existing file
    touch("good.jpg");

    // I think you know this one.
    echo("All files");

    // print out all files in the current directory.
    find("*.*", recursive=false).forEach((line) => print(line));

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
    delete("bad.jpg", ask: false);

    // return to the directory we were in
    // before we called push above.
    pop();
  
    // Print out our current working directory.
    echo(pwd);
}
```

As you can see we have achieved much of the power of Bash without any of the ulgy grammar and whats more we only used one type of quote!

DScript is the kind of friend that you actually introduce Grandma to.

# running a script
Once dshell is installed you can run a dshell script just as you do with bash.

Add the shebang at the top of the script:
Note: it must be the very first line!

```dart 
#! /usr/bin/env dshell
```

Save the file to something like: tryme.dart

Mark the file as executable

```bash
chmod +x  tryme.dart
```

Now run the script from the cli:

```bash
> ./tryme.dart
```

Your now offically in the land of dshell magic.

# Calling cli applications

DShell can call any console application.

DShell does the nasty with the String class using Dart's (2.6+) 'extension' feature.
The aim of this somewhat unorthodox approach is to deliver the elegance that Bash achieves when
calling cli applications.

To achieve this we add a number of methods and operator overlaods to the String class.

These include:
* run
* forEach(LineAction stdout, {LineAction stdout})
* List<String> toList()
* | operator

This is the resulting syntax:

```dart
    // run wc on a file
    // all wc output goes directly to the console
    'wc fred.text'.run

    // run grep, printing out each line but suppressing stderr
    'grep import *.dart'.forEach((line) => echo(line)) ;

    // run tail printing out stdout and stderr
    'tail fred.txt'.forEach((line) => echo(line)
        , stderr: (line) => print(line)) ;

```


# Piping

Now lets pipe the output of one cli command to another.

```dart

    'grep import *.dart' | 'head 5'.forEach((line) => print(line)) ;

```

The above command launches 'grep' and 'head' to find all import lines in any dart files and then trim the list (via head) to the first five lines and finally print those lines.

What we have now is the power of Bash and the elegance of Dart.


# Installing

To install dshell run:

Note: i had a problem with my installation where the flutter internal verion of the dart-sdk was
on my path before the os version. I don't believe the flutter dart-sdk should be on your path.
Removing it from my path allowed me to developed cli apps as well as flutter.


```shell
pub global activate dshell
```


# Running scripts

Dshell provides a number of methods to run our bash like commands.

The most bash like method lets you directly run a single file script.


To run the following script save the file to tryme.dart.

```dart
#! /usr/bin/env dscript

import 'package:dshell/dshell.dart';

main()
{
    echo("Hello World");
    echo("Where are we: $(pwd}?");

    createDir("test");
    push("test");
    touch("icon.png");
    touch("logo.png");
    touch("dog.png");

    // print all the file names in the current directory.
    find("*.*", recursive: false).forEach((file) 
        => print("Found: ${file}"));

    touch("subdir/monkey.png");

    // do a recursive find for .png files.
    find("*.png").forEach((file) => print("$file"));


    // now cleanup
    delete("icon.png");
    delete("logo.png");
    delete("dog.png");

    pop();

    'grep touch tryme.dart'.forEach((line) 
        => print("Grepo: $line"));
}

```
# Pubspec Management
dshell aims to make creating a script as simple as possible and with that in mind we 
provide a number of ways of creating and managing your pubspec.yaml.

By default you do NOT need a pubspec.yaml when using dshell.

If dshell doesn't find a pubspec then it will automatically create a default pubspec for you.
The default pubspec is stored in the script's Virtual Project cache (under ~/.dshell/cache).

We refer to this as your 'virtual pubspec'.

Each time you run a dshell script, dshell checks that your virtual pubspec is
up to date and if necessary will recreate it to reflect your current script.


## Pubspec dependancy inject
Each time dshell recreates your virtual pubspec it will (if needed) inject a default set of dependancies.

The default dependancies are:

* dshell
* path
* args


When we create a default pubspec definition additional rules are applied.

dshell aims to make creating a script as simple as possible and with that in mind we 
inject a number of common dependancies into 


inject a number of common dependancies into 


## Pubspec Precendence
dshell allows you to define your pubspec  either via a  pubspec annotation within your script or a traditional
pubspec.yaml which lives in the same directory as you script.

dshell also support the concept of allowing multiple single file dshell scripts to exist
in the same directory.

This has the potential to create ambiguities as to which pubspec definition is to be used.

To remove the ambiguities the pubspec rules are used and applied in the following order:
1) If the script contains a pubspec annotation use it.
2) If the scripts directory contains a pubspec.yaml use it.
3) If 1) and 2) fail then create a default pubspec definition.





## External packages

When writing dart programs we regularly want to use external packages. Dshell scripts are no different.

But where do we place our pubspec.yaml?

The whole point of dshell is to allow you to create a single file with everything you need, to that end
dshell allows you to specify your pubspec.yaml directly within the script using the @pubspec annotation.


```dart
#! /usr/bin/env dscript

/*
@pubspec.yaml
name: tryme
dependencies:
  money2: ^1.0.3
*/

import 'package:dshell/dshell.dart';
import 'package:money2/money2.dart';

main()
{
    Currency aud = Currency.create("AUD", 2);
    Money notMuch = Money.parse("\$2.50", aud);

    echo("Hello World");
    echo("All I have is ${notMuch}");
}
```

## Multi-file scripts

As with all little projects they have a habit of getting larger than expected.
At some point you are going to want to spread you script over multiple dart libraries.

Well dshell supports this as well.

If you need to create additional libraries (.dart files) create a subdirectory called 'lib', which shouldn't be too much of a surprise.


Place the following file in:
    
    ~/myproject/tryme.dart

```dart

#! /usr/bin/env dscript

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

    ./tryme.dart


# Compiling to Native Executable
## TODO document compiling to native

# Contributing
Read the wiki on contributing to dshell

https://github.com/bsutton/dshell/wiki

# References

Projects I referenced (stole stuff from) when making this package:

https://pub.dev/packages/dscript_exec

https://pub.dev/packages/dartx

https://pub.dev/packages/completion
