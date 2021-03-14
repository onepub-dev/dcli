# Dart on Linux - the perfect CLI dev tooling

If you haven't already heard, Google and Canonical have released a [joint statement ](https://medium.com/flutter/announcing-flutter-linux-alpha-with-canonical-19eb824590a9)announcing Linux as a first-class Flutter platform.

{% hint style="info" %}
Dart is the perfect language for building CLI apps and scripts
{% endhint %}

You can now build Linux desktop applications using Dart and Flutter. The fact that Canonical is redeveloping the Ubuntu  installer in Flutter demonstrates their level of commitment to Flutter.

{% hint style="info" %}
Canonical is redeveloping the Ubuntu installer in Flutter.
{% endhint %}

If you are not familiar with Dart, it is a new language released by Google and it is now the [fastest growing](https://www.linkedin.com/pulse/google-dart-tops-githubs-list-fastest-growing-2019-bill-detwiler#:~:text=According%20to%20GitHub's%20annual%20%22The,tagged%20with%20a%20primary%20language.) language on Github. Flutter is a cross platform graphical framework written in Dart supporting ios, android, windows, linux, osx along with linux arm support \(yes it runs on your raspberry pi\).

{% hint style="info" %}
Even if you have no intent of using Flutter, you should look at Dart for building CLI apps.
{% endhint %}

As an old hack that started my career in C and 6502 assembler and has worked professionally with some dozen or more languages I like to say that 'Dart is Delightful'.  It's an elegant language that brings simple solutions to common programming problems.

{% hint style="info" %}
Dart is Delightful to work with.
{% endhint %}

Dart is easy to learn and the development tooling is really easy to work with. It's often been called the love child of Java and Javascript.  It takes the best of these languages and removes the cruft.

At Noojee \(the company I work for\) we have 10s of thousands of lines of CLI code we use to support our production environment.  This CLI code had been written in Bash, Perl, Ruby, Go, Rust, Python... In short, it was a mess and hard to maintain.  

When we started working on a Flutter project we fell in love with Dart and saw a path to solve our maintenance problems with our CLI code.

Dart looked to be the perfect tool to replace all of our CLI apps and scripts. No more would we have to deal with archaic Bash and Perl scripts and no more magic Ruby code. We could convert all our scripts to Dart and use a single  language for our production GUI and management tooling.

But the real pay off is that Dart is so simple to learn that any of our development team could help maintain CLI scripts and apps with almost no ramp time, try doing that with a Perl script.

Of course life is never as simple as it first looks.

### The Future is not so bright

Dart supports the concept of Futures. Futures are like Javascript Promises. Essentially a future tells the Dart VM that I'm going to do some work that will take a little while, so go and do something else and I will let you know when I'm done.  Think of a Future as a super lightweight thread.  A function that returns a Future is an async function.

Futures are great for a gui app, particularly a mobile app, in that you need the GUI to be responsive even when you are fetching data or doing some large calculations.

The problem is that when writing a CLI app you really don't need to have a responsive UI and in fact Futures just make your life harder. Imagine the following code:

```dart
await createDir('/home/me');
await touch('/home/me/mything');
```

The createDir and touch functions are async functions which in Dart are implemented as Futures.

The 'await' statement tells dart to 'wait' for the function to finish before executing the next line.

Well, in a CLI application, just about every function call would need to be 'awaited' which is just tedious and gives zero benefits.

In fact in our early experiments with Dart, Futures were the cause of a multitude of disasters as it's very easy to forget to await each function \(the latest dart linter does resolve this issue but at the time it was a significant issue\).

Imagine in the above example if we had forgotten to await the createDir call. The result would be that the touch call would fail as the /home/me directory wouldn't exist as yet.

### waitFor to the rescue

The Dart CLI library has a solution for this; 'waitFor'.  The waitFor command essentially tells Dart to change the async function \(the Future\) into a blocking function which is just perfect for CLI applications.

So we now had a path that made sense but we needed a common library for our team to share code.

## And DCli is born

And from that need was born DCli.  DCli is a library of functions and classes designed specifically for creating CLI apps and scripts.

A founding principle of the libraries is that developers should never have to worry about Futures. Internally each of the DCli functions calls waitFor so that you don't need to think about futures. The above code simply becomes:

```dart
createDir('/home/me');
touch('/home/me/mything');
```

### Don't reinvent the wheel

One of the superpowers of Bash is that it makes it easy to call other CLI applications and process the output:

```bash
grep honda cars.txt | head > tophondas.txt
```

Whilst personally I despise Bash and its less than elegant syntax, you have to give it due credit for its ability to interact with other cli apps.

In order to be able to replace our Bash scripts without re-inventing every linux app, it was going to be important that we were able to call existing cli apps just as Bash does.

```dart
var hondas = ('grep honda carts.txt' | 'head').toList();

for (final honda in hondas)
{
    'tophondas.txt'.append(honda);
}
```

We view the DCli libraries ability to call external apps as so important that the library exposes more than a dozen methods for calling external apps and processing their output.

Here are some samples

```dart
'tail /var/log/syslog'.run;
'tail syslog'.start(workingDirectory: '/var/log', privileged: true);
var top = 'tail syslog'.firstLine;
```



### And the adventure begins

Over the past 18+ months the DCli library has grown into a sophisticated library providing all the tools required to build both simple and complex CLI applications.

DCli now consists of over 20K lines of code and internally Noojee now has over 100K lines of Dart/DCli  running our production systems.

We have also developed a number of full blown apps using Dart and DCli:

#### Nginx-LE

A Docker container for Nginx with Lets Encrypt support baked in.

{% embed url="https://github.com/bsutton/nginx-le" %}

#### DSwitch

Switch between Dart channels \(stable, beta, dev\).

{% embed url="https://github.com/bsutton/dswitch" %}

#### DCli Scripts

A eclectic collection of scripts written in Dart and DCli

[https://github.com/bsutton/dcli\_scripts](https://github.com/bsutton/dcli_scripts)

## At the end of the day

Dart is a fantastic language and paired with DCli ,it really is the perfect language for building CLI apps and scripts.

Our dev and ops team love working with Dart and I think your team will too.

Dart and DCli are able to deliver all the pieces you require from a CLI development tool with none of the compromises.

Together Dart and DCli deliver

* Speed - Dart is fast 
* Ease of learning - Dart is simple to learn, often described as the love child of Java and Javascript
* JIT or compiled - A Dart file can be run directly \(JIT\) or it can be compiled into a stand alone exe.
* Shebang support
* Large ecosystem of third party libraries vi a [pub.dev](https://pub.dev)
* Dart and DCli are Cross platform \(Linux, Windows and OSX\)
* Access to OS native system calls via [dart posix](https://pub.dev/packages/posix) and C libraries via [ffi](https://dart.dev/guides/libraries/c-interop)
* [Easy to install](https://dart.dev/get-dart)

If you want to give Dart and DCli a go I would recommend the following reading:

[https://dart.dev/get-dart](https://dart.dev/get-dart)

[Dart Language Tour](https://dart.dev/guides/language/language-tour)

[Installing DCli](getting-started/)

[Writing your first CLI App](writing-your-first-script.md)

## The full enchilada

Just in case you don't believe me regarding how easy it is. Here is a fully worked example:

```dart
sudo apt install dart
pub global activate dcli
dcli install
mkdir hellow
cd hellow
dcli create hello.dart
```

Copy the following text over the contents of hello.dart

```text
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

void main() {
  var name = ask('name:', required: true, validator: Ask.alpha);
  print('Hello $name');
  var pathToTestMe = join(HOME, 'testme');
  
  if (!exists(pathToTestMe))
  {
    createDir(pathToTestMe);
  }
  
  var pathToTxt = join(pathToTestMe, 'test.txt');
  pathToTxt.write('Hello $name');
  
  'cat $pathToTxt'.run;
}
```

And to run the script.

```dart

./hello.dart
```

Maybe you need better performance:

```dart
dcli compile hello.dart
./hello
```

Add hello to your path:

```dart
dcli compile --install --overwrite hello.dart
hello
```

### 









