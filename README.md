# README

See the online [gitbook](https://bsutton.gitbook.io/dcli/) for DCli


If you enjoyed DCli maybe you could help out with a sponsorship or just buy me a coffee.

[:heart: Sponsor Me](https://github.com/sponsors/bsutton)


DCli is an API and tooling for building cross platform command line \(CLI\) applications and scripts using the Dart programming language.

DCli - pronounced d-cli


# Another Dart tool by Noojee

![Noojee](https://github.com/bsutton/dcli/blob/master/images/noojee-logo.png?raw=true)

## Looking for DShell? You are in the right place.

DShell has been renamed DCli to better reflect its intended purposes. 

# Overview
DCli is intended to to allow you to create Command  Line (CLI) Applications from simple scripts to full blown CLI apps. 

DCli is a great replacement for CLI apps that would have traditionally been built with Bash, C, python, ruby, Go, Rust ....

Whether its a 5 line Bash script or a 100,000 line production management system (like we run internally) DCli is the right place to start building your CLI infrastructure.
# So why DCli?
DCli is based on Dart which is a modern programming language that has a set of features that makes building CLI apps easy and reliable.
* Dart and DCli are simple to learn
* Compiled or JIT 
* Shebang support (run .dart scripts directly from the cli ./hellow.dart)
* Small transportable execs (from 10MB), Dart VM is NOT required on target system.
* Typesafe language catches errors at compile time
* Sound null safety reduces null pointer exceptions
* Fast
* Great development environment using vs-code
* Local and Remote development/debugging 
* Cross platform supporting Linux/Windows/osx/arm

# Example:
```
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

void main() {
  var name = ask('name:', required: true, validator: Ask.alpha);
  print('Hello $name');

}
```
To run the above script called hello.dart:

`./hello.dart`

# So why is DCli different?
DCli is based on the relatively new programming language; [Dart](https://dart.dev/).

Dart is currently the [fastest growing language](https://www.linkedin.com/pulse/google-dart-tops-githubs-list-fastest-growing-2019-bill-detwiler#:~:text=According%20to%20GitHub%27s%20annual%20%22The,tagged%20with%20a%20primary%20language) on github and is the basis on which Flutter is built.

[Ubuntu has just announced](https://medium.com/flutter/announcing-flutter-linux-alpha-with-canonical-19eb824590a9) that Flutter will be the primary platform for building GUI's on Ubuntu and is currently working on replacing the Ubuntu installer using Flutter.

You can now use Dart to build GUI's on Android, IOS, Windows, OSX, Linux and the Web, server side applications and with DCli you can also target console apps.

Image the benefits of using a single language across you complete ecosystem.

Dart is a simple to learn, and uses the all too familiar 'C' style syntax. I've heard Dart described as the love child of Java and JavaScript. If you come from either of these environments you will find Dart easy to work with.


Being easy to learn also helps with the maintenance cycle of you CLI apps. You no longer need a specialised developer, as anyone that has even a vague familiarity with Java, Javascript or C, ... will be right at home with Dart in a couple of days.

Dart and DCli are easy to install; DCli makes it a breeze to create simple scripts and provides the tools to manage a script that started out as 100 lines but somehow grew to 10,000 lines.

Dart has is also a large and growing ecosystem of [third party libraries](https://pub.dev/) that you can include in your CLI app with no more than an import statement and a dependency declaration.

Dart is fast and if you need even more speed it can be compiled to a single file executable that is portable between binary compatible machines.

```
# compile, install to the local PATH and run hello.dart

$> dcli compile --install hello.dart
$> hello
name: brett
Hello brett


# copy to a remote machine (where dart is NOT installed)
$> scp hello remote.domain.com:

# login to remote machine and run the app hello
$> ssh remote.domain.com
./hello
name: brett
Hello brett
```

You can use your favourite editor to create DCli scripts. Vi or VIM work fine but Visual Code is recommended.

Use Visual Code for the best development experience with Dart.

Visual Code with the dart-code extension provide a great development an debugging experience including the ability to develop and debug code on a remote server.
