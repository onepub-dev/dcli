DShell is intended to provide a replacement for bash and similar shell scripting language with Dart.

Bash has been the go to tool for scripting file system operations for decades and it provides a wealth 
of really useful tools.

Bashes power lies in its ability to chain multiple commands together to provide a quick (and often dirty) solution.

Bash has an elegant set of commands for common file operations such as mv, cp, rm etc.

So why DShell?

Whilst Bash is a powerful tool it has a grammar that would make your Grandma blush.

It useage of quotes can only be described as..., oh wait, it so complex its indescribable.

For a long time I've wanted to build a replacement tool that has the elegance of a modern language with the power of bash.

DShell is hopefully that.

DShell uses the elegant and simple dart language with a set of functions (commands) that mimick bashes operations.

Like bash it provides an extensive set of commands to assist with the manipulation of the file system as well as the abilty 
to call any existing cli application.

DShell also lets you chain multiple operations using pipes, just like bash.

Finally, like Bash, DShell allows you to write and execute simple scripts without the need to build a dev environment but also 
delivers the power of the Dart native compiler for more taxing scripts.

DShell relies on DScript to provide instance execution of DShell scripts, but more on that later.

DScript: https://pub.dev/packages/dscript

Lets start by looking at the some of the built in commands that DShell supports:

```dart

import 'package:dshell/dshell.dart';

void main() {
    Settings().debug_on = true;

    // Print the current working directory
    print("PWD: ${pwd}");

    // Change to the directory 'main'
    cd("main");

    // Create a directory with any needed parents.
    makeDir("tools/images", createParent: true);

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
    // fileList is a DShell property.
    for (var file in fileList) {
        print(file);
    }

    // take a nap for a couple of seconds.
    sleep(2);

    echo("Find file matching *.jpg");
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find("*.jpg")) {
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

# Calling cli applications

DShell can also call any console application.

Note: This feature is still a work in progress and these examples may not be the final syntax.

DShell does the nasty with the String class using the latest Dart 2.6 'extension' feature.
The aim of this somewhat unorthodox approach is to deliver the elegance that Bash achieves when
calling cli applications.

To achieve this we add a 'run' method to the String class as well as overloading the '|' operator.

This is the resulting syntax:

```dart

    'grep import *.dart'.run.forEach((line) => echo(line)) ;

```

The above command runs the command line 'grep' tool and then prints each matching line to the console.

# Piping

Now lets pipe the output of one cli command to another.

```dart

    'grep import *.dart' | 'head 5'.run.forEach((line) => echo(line)) ;

```

The above command launches 'grep' and 'head' to find all import lines in any dart files and then trim the list (via head) to the first five lines and finally print those lines.

What we have now is the power of Bash and the elegance of Dart.



