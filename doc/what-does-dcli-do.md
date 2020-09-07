# What does DCli do?

DCli has a singular focus: 

{% hint style="info" %}
make it easy to build command line apps using the Dart programming language.
{% endhint %}

DCli has the following aims

* make building CLI apps as easy as walking.
* fully utilise the expressiveness of Dart
* works seamlessly with the core Dart libraries.
* make debugging CLI apps easy
* generate error messages that make it easy to resolve problems
* provide quality documentation and examples
* Executes commands synchronously, so no need to worry about futures.
* Chain multiple cli commands using pipes
* Optionally compile scripts to a standalone native executable.
* Write and execute single file scripts
* Allows you to call any cli application in a single line

DCli's API covers a number of core areas:

## User input

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

## Displaying information

Out of the box dart provides the basic 'print' statement which DCli extends to provide common features.

* print
* printerr - prints to stderr.
* colour coding
* cursor management
* clear screen/clear line

## Manage files and directories

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

## Read/Write files

You are often going to need to read/write and modify text and binary files.

* read
* write
* truncate
* append
* replace
* tail
* cat

{% hint style="info" %}
You still have full access to the core Dart APIs as well as [ffi](https://dart.dev/guides/libraries/c-interop) to call native C libraries.
{% endhint %}

```dart
var settings = 'myfile.settings';
settings.write('[section1]');
settings.append('color=red');
settings.append('color=blue');

replace(settings, 'color', 'colour');
```

## Call command line apps

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

## Explore you environment

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

And the ability to explore the Dart environment.

```dart
/// Get details of the current dart script that is running.
Script.current;
DartSdk().pathToDartExe;
PubCache().pathTo;
```

## 

