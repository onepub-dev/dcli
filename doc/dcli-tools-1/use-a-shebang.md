# Use a shebang \#!

A Shebang is a special entry on the first line of your script that tells the OS which command interpreter to use to execute your script.

{% hint style="info" %}
Shebangs are currently only supported on Linux and OSx.
{% endhint %}

By adding a Shebang to the start of you Dart script you can directly run a script from the cli.

Without a Shebang:

```bash
dart hello.dart
```

With a Shebang:

```bash
./hello.dart
```

It's a small difference but rather useful particularly if you are calling one script from another.

{% hint style="info" %}
To use a shebang you must have activated the optional DCli command line tools.
{% endhint %}

You do NOT need the DCli tools if you just want to use the DCli API but they are required if you want to use the Shebang feature.

If you want to use the DCli tools you must first activate them.

```bash
dart pub global activate dcli
dcli install
```

So let's look at how hello.dart looks with a shebang added.

{% hint style="info" %}
The Shebang \#! must be the very first line!
{% endhint %}

```dart
#! /usr/bin/env dcli

/// import DCli's global functions 
import 'package:dcli/dcli.dart';

void main() {
  print('Hello World');
}
```

On Linux and OSX you must mark the file as executable for the Shebang to work.

Mark the file as executable:

```bash
chmod +x  hello.dart
```

{% hint style="info" %}
if you used the `dcli create <script>` command then DCli will have already set the execute permission on your script and added the shebang!
{% endhint %}

Now run the script from the cli:

```bash
cli> ./hello.dart
Hello world
cli>
```

You're now officially in the land of DCli magic.

Faster you say?

Read the section on [compiling](../#compiling-to-native) your script to make it run even faster.

