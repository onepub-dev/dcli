# Introduction

DCli is an API and tooling for building cross platform command line \(CLI\) applications and scripts using the Dart programming language.

{% hint style="info" %}
Looking for DShell? You are in the right place. DShell has been renamed DCli.
{% endhint %}

DCli as featured on Jermaine Oppong package of the week vlog.

{% embed url="https://youtu.be/z99IxxWmD1Q" %}

But I call it D-cli not d.c.l.i ;\)

## Overview

DCli is intended to to allow you to create Command  Line \(CLI\) Applications from simple scripts to full blown CLI apps. 

DCli is a great replacement for CLI apps that would have traditionally been built with Bash, C, python, ruby, Go, Rust ....

Whether its a 5 line Bash script or a 100,000 line production management system \(like we run internally\) DCli is the right place to start building your CLI infrastructure.

### So why DCli?

DCli is based on Dart which is a modern programming language that has a set of features that makes building CLI apps easy and reliable.

* Dart and DCli are simple to learn
* Compiled or JIT 
* Shebag support \(run .dart scripts directly from the cli ./hellow.dart\)
* Small transportable execs \(from 10MB\), Dart VM is NOT required on target system.
* Typesafe language catches errors at compile time
* Sound null safety reduces null pointer exceptions
* Fast
* Great development environment using vs-code
* Local and Remote development/debugging 

### Example:

```text
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

void main(List<String> args) {
  var name = ask('name:', required: true, validator: Ask.alpha);
  print('Hello $name');

}
```

To run the above script called hello.dart:

```text
./hello.dart
```

### So why is DCli different?

DCli is based on the relatively new programming language; [Dart](https://dart.dev/).

Dart is currently the fastest growing language on github and is the basis on which Flutter is built. If you have not heard of flutter then you should have a look, but I digress.

If you have used multiple languages you well know how the learning curve goes. Its usually doesn't take long to the get to the point where you love or hate a language. As you begin to discover the little nooks and crannies of a language you either despise the designer's solutions or fall in love with it.

For me at least, it was love at first sight.

Dart is a simple to learn, and uses the all too familiar 'C' style syntax. I've heard Dart described as the love child of Java and JavaScript. If you come from either of these environments you will find dart easy to work with.

{% hint style="info" %}
**Dart is the love child of Java and JavaScript. In short, Dart is delightful.**
{% endhint %}

Dart provides elegant solutions for common problems and from a scripting perspective hits all of the high notes.

DCli excels in all of the functionality that you expect from Bash and then takes you to the next level.

DCli is easy to install; makes it a breeze to create simple scripts and provides the tools to manage a script that started out as 100 lines but somehow grew to 10,000 lines.

Dart has is also a large and growing eco-system of [third party libraries](https://pub.dev) that you can included in your script with no more than an import statement and a dependency declaration.

Dart is fast and if you need even more speed it can be compiled to a single file executable that is portable between binary compatible machines.

You can use your favourite editor to create DCli scripts. Vi or VIM work fine but Visual Code is recommended.

{% hint style="success" %}
**Use Visual Code for the best development experience with Dart.**
{% endhint %}

DCli and Dart also make it harder to make some of the common mistakes that Bash invites.

With Dart and DCli you have the option to use static typing. This is a bit of a controversial issues \(particularly if you are coming from JavaScript\), so DCli doesn't force you to type your scripts but I ALWAYS use types and you should too.

For a long time I've wanted to build a replacement tool that has the elegance of a modern language, with the power of Bash.

DCli is hopefully that.

