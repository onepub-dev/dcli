# Introduction

DCli is the console SDK for Dart.

Use the DCli console SDK to  build cross platform, command line (CLI) applications and scripts using the Dart programming language.

The DCli  (pronounced d-kleye) console SDK includes command line tools and an extensive API for building CLI apps.

The DCli console SDK as featured on Jermaine Oppong package of the week vlog.

{% embed url="https://youtu.be/z99IxxWmD1Q" %}

## Sponsored by OnePub

Help support DCli by supporting [OnePub](https://onepub.dev/drive/a50d4f6f-e0fb-40bd-af7b-2dcc295b0332), the private dart repository.

OnePub allows you to privately share Dart packages across your Team and with your customers.

Try it for free and publish your first private package in seconds.

| ![](<.gitbook/assets/OnePub.dev Logo – reversed FA (1) (1) (1) (1) (1) (1) (1).svg>) | <p>Publish a private package in six commands:</p><p><mark style="color:green;"><code>dart pub global activate onepub</code></mark></p><p><mark style="color:green;"><code>onepub login</code></mark></p><p><mark style="color:green;"><code>dcli create --template=full mytool</code></mark></p><p><mark style="color:green;"><code>cd mytool</code></mark></p><p><mark style="color:green;"><code>onepub pub private</code></mark></p><p><mark style="color:green;"><code>dart pub publish</code></mark></p> |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

You can now install `mytool` on any system with dart installed:

```bash
dart pub global activate onepub
onepub login
onepub pub global activate mytool
```

## Overview

The DCli console SDK is intended to to allow you to create Command Line (CLI) Applications from simple scripts to full-blown CLI apps.

DCli is a great replacement for CLI apps that would have traditionally been built with Bash, C, Python, Ruby, Go, Rust ....

Whether it's a 5 line Bash script or a 100,000 line production management system (like we run internally) DCli is the right place to start building your CLI infrastructure.

### So why DCli?

DCli is based on Dart which is a modern programming language that has a set of features that makes building CLI apps easy and reliable.

* Dart and DCli are simple to learn
* Compiled or JIT
* Shebag support (run .dart scripts directly from the terminal ./hellow.dart)
* Small transportable execs (from 10MB) and the Dart VM is NOT required on the target system.
* Typesafe language catches errors at compile time
* Sound null safety reduces null pointer exceptions
* Fast
* Great development environment using vs-code
* Local and Remote development/debugging
* Cross-platform supporting Linux/Windows/MacOS/ARM

### Example:

```dart
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

void main() {
  var name = ask('name:', required: true, validator: Ask.alpha);
  print('Hello $name');
  
  print('Here is a list of your files');
  find('*').forEach(print);
  
  print('let me copy your files to a temp directory');
  withTempDir((pathToTempDir) {
      moveTree(pwd, pathToTempDir);
  });
}
```

To run the above script called hello.dart:

```
./hello.dart
```

### So why is DCli different?

DCli is based on the relatively new programming language; [Dart](https://dart.dev/).

Dart is currently the [fastest growing language on github](https://www.linkedin.com/pulse/google-dart-tops-githubs-list-fastest-growing-2019-bill-detwiler) and is the basis on which Flutter is built.

The [Ubuntu](https://medium.com/flutter/announcing-flutter-linux-alpha-with-canonical-19eb824590a9) installer is now based on Flutter and Flutter will be the primary platform for building GUI's on Ubuntu.

You can now use Dart to build GUI's on Android, IOS, Windows, OSX, Linux. Dart is also suitable for building Web Servers and server-side applications and of course, with DCli you can also target console apps.

Imagine the benefits of using a single language across your complete ecosystem.

Dart is simple to learn and uses the all too familiar 'C' style syntax. I've heard Dart described as the love child of Java and JavaScript. If you come from either of these environments you will find Dart easy to work with.

{% hint style="info" %}
**Dart is the love child of Java and JavaScript and is delightful to work with.**
{% endhint %}

Being easy to learn also helps with the maintenance cycle of your CLI apps. You no longer need a specialized developer, as anyone who has even a vague familiarity with Java, Javascript, or C, ... will be right at home with Dart in a couple of days.

Dart and DCli are easy to install; DCli makes it a breeze to create simple scripts and provides the tools to manage a script that started out as 100 lines but somehow grew to 10,000 lines.

Dart has a large and growing ecosystem of third-party[ libraries](https://pub.dev) that you can include in your CLI app with no more than an import statement and a dependency declaration.

Dart is fast and if you need even more speed it can be compiled into a single file executable that is portable between binary-compatible machines.

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

You can use your favorite editor to create DCli scripts. Vi or VIM work fine but Visual Code is recommended.

{% hint style="success" %}
**Use Visual Code for the best development experience with Dart.**
{% endhint %}

Visual Code with the `dart-code` extension provides a great development and debugging experience including the ability to develop and debug code on a remote server.
