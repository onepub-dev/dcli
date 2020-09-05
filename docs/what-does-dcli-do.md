# What does DCli do?

DCli has a singular focus: make it easy to build command line apps.

DCli aims to fully utilise the expressiveness of Dart to make building CLI apps as natural as walking.

DCli's API also works seamlessly with the core Dart libraries.

DCli's API covers a number of core areas:

### User input

Asking the user to input data into a CLI application should be simple. DCli provide a number of core methods to facilitate user input.

* ask
* confirm
* menu

```dart
var username = ask('Username:', validator: Ask.required);
if (confirm('Are you over 18')) {
    print(orange('Welcome to the club'));
}

var selected = menu('Select your poision', options: ['beer', 'wine', 'spirits']
   defaultOption: 'beer');
print(green('You chose $selected'));
```

{% hint style="info" %}
**DCli provide an extensive API designed specifically for building command line apps.**
{% endhint %}

### Displaying information

Out of the box dart provides the basic 'print' statement which DCli extends to provide common features.

* print
* printerr - prints to stderr.
* colour coding
* cursor management
* clear screen/clear line

### Manage files and directories

A fundamental task of most CLI applications is the management of files and directories. DCli provides a large set of tools for file management.

* find
* which
* copy
* copyTree
* move
* moveTree
* delete
* deleteDir
* touch
* exists
* isWritable/isReadable/isExecutable
* isFile
* isLink
* isDirectory
* lastModified

{% hint style="info" %}
DCli ships with the excellent [paths](https://pub.dev/packages/path) package that lets you easily manipulate file paths.
{% endhint %}

```dart
if (!exists('/keep')) {
    createDir('/keep');
}

var images = find('*.png', root: '/images');
for (var image in images) {
    if (image.startsWith('nsfw')) {
        copy(image, '/keep');
    }
}
```

### Read/Write files

You are often going to need to read/write and modify text and binary files. 

* read
* write
* truncate
* append
* replace
* tail
* cat

{% hint style="info" %}
You still have full access to the  core Dart APIs as well as [ffi](https://dart.dev/guides/libraries/c-interop) to call native C libraries.
{% endhint %}

```dart
var settings = 'myfile.settings';
settings.write('[section1]');
settings.append('color=red');
settings.append('color=blue');

replace(settings, 'color', 'colour');
```

### Call any command line app

A core feature of bash is the ability to call other CLI apps and process their output. DCli provides the same facilities.

* run
* start
* toList
* forEach
* firstLine
* lastLine
* \| \(pipe\)
* stream

Run mysql with all output being displayed to the console.

```dart
var user = ask('username');
var password = ask('password', hidden:true);
'mysql -u $user --password=$password customerdb -e "select 1"'.run;
```

DCli also makes it easy to process the output of a command.

```dart
var users = 'mysql customerdb -e "select fname, sname from user"'
    .toList(skipLines: 1);
for (var user in users) {
    var parts = user.split(',');
    print('Firstname: ${parts[0]} Surname: ${parts[1]});
}

'grep error /var/lib/syslog'.forEach((line) => print(line));
```

### Explore you environment

DCli makes it easy to explore your environment with direct manipulation of environment variables.

```dart
var user = env['USER'];
env['JAVA_HOME'] = '/usr/lib/java';
```

PATH management tools:

```dart
Env().appendToPath('/home/me/bin');
Env().addToPATHIfAbsent('/home/me/bin');
Env().removeFromPATH('/home/me/bin');
```

You can also explore the Dart environment.

```dart
/// Get details of the current dart script that is running.
Script.current;
DartSdk().pathToDartExe;
PubCache().pathTo;
```

### Shebang \(\#!\) support

As DCli is focused on building command line scripts it wouldn't be complete without [Shebang](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) support.

Out of the box dart will allow you to run a dart script from the command line:

Create the classic hello world script and call it hello.dart.

```dart
void main() {
    print('hello world');
}
```

Now its ready run:

```bash
dart hello.dart
> hello world
```

By adding a  shebang \(\#!\) at the top of your dart file allows you to directly run your script:

```dart
#! /usr/bin/env dcli
void main() {
    print('hello world');
}
```

You can run your script directly \(after a little prep\)

```dart
chmod +x hello.dart
./hello.dart
> hello world
```





