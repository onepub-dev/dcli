
# DShell - a bash replacement using dart

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

## What commands that DShell support

DShell ships with a number of built in commands and the abilty to call any cli application and easily process the output.

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


Let's start by looking at the some of the built in commands that DShell supports. 

The built-in commands are dart global functions providing a very bash like feel to writing DShell scripts.
The commands make strong use of named arguments with intelligent defaults so mostly you can use the minimal form of the command.

Take note, there are no Futures here. Each command runs synchronously.

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

As you can see we have achieved much of the power of Bash without any of the ugly grammar, and what's more we only used one type of quote!

DScript is the kind of friend that you actually introduce Grandma to.

# Running a script
Once DShell is installed, you can run a DShell script just as you do with bash.

Add the shebang at the top of the script:

(Note: it must be the very first line!)

```dart 
#! /usr/bin/env dshell
```

Save the file to something like: tryme.dart

Mark the file as executable:

```bash
chmod +x  tryme.dart
```

Now run the script from the cli:

```bash
> ./tryme.dart
```

You're now offically in the land of DShell magic.

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

Now let's pipe the output of one cli command to another.

```dart

    'grep import *.dart' | 'head 5'.forEach((line) => print(line)) ;

```

The above command launches 'grep' and 'head' to find all import lines in any dart files and then trim the list (via head) to the first five lines and finally print those lines.

What we have now is the power of Bash and the elegance of Dart.


# Installing

To install DShell run:

```shell
pub global activate dshell
```

Note: I had a problem with my installation where the flutter internal verion of the dart-sdk was
on my path before the os version. I don't believe the flutter dart-sdk should be on your path.
Removing it from my path allowed me to developed cli apps as well as flutter.

# Running scripts

DShell provides a number of methods to run our bash like commands.

The most bash-like method lets you directly run a single file script.


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

## External packages

When writing dart programs we regularly want to use external packages. DShell scripts are no different.

But where do we place our pubspec.yaml?

The whole point of dshell is to allow you to create a single file with everything you need, to that end
DShell allows you to specify your pubspec.yaml directly within the script using the @pubspec annotation.


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

Well, DShell supports this as well.

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


## TODO document compiling to native

# References

Projects I referenced (stole stuff from) when making this package:

https://pub.dev/packages/dscript_exec

https://pub.dev/packages/dartx

https://pub.dev/packages/completion
