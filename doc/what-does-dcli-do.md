# What does DCli do?

DCli has a singular focus:

{% hint style="info" %}
make it easy to build command line apps using the Dart programming language.
{% endhint %}

DCli has the following aims:

* make building CLI apps as easy as walking.
* fully utilise the expressiveness of Dart.
* works seamlessly with the core Dart libraries.
* provide a cross platform API for Windows, OSx and Linux.
* call any CLI app.
* make debugging CLI apps easy.
* generate error messages that make it easy to resolve problems.
* provide quality documentation and examples.

## DCli's API covers a number of areas:

## User input

Asking the user to input data into a CLI application should be simple. DCli provides a number of functions to facilitate user input.

* ask
* confirm
* menu

```dart
import 'package:dcli/dcli.dart';
void main(){
   var username = ask('Username:', validator: Ask.required);
   if (confirm('Are you over 18')) {
       print(orange('Welcome to the club'));
   }
   
   var selected = menu('Select your poison', options: ['beer', 'wine', 'spirits']
      defaultOption: 'beer');
   print(green('You choice was: $selected'));
}
```

{% hint style="info" %}
**DCli provides an extensive API designed specifically for building command-line apps.**
{% endhint %}

## Displaying information

Out-of-the-box Dart provides the basic 'print' statement which DCli extends to provide common features.

* print
* printerr - prints to stderr.
* colour coding
* cursor management
* clear screen/clear line

```dart
print(orange("I'm an important message"));
printerr(red('Oops, something went wrong here'));
```

## Manage files and directories

A fundamental task of most CLI applications is the management of files and directories. DCli provides a large set of tools for file management such as:

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
Dart has a large ecosystem of packages that you can use to extend the DCli such as the excellent [paths](https://pub.dev/packages/path) package that lets you easily manipulate file paths.
{% endhint %}

```dart
import 'package:dcli/dcli.dart';
void main() {
    if (!exists('/keep')) {
        createDir('/keep');
    }
    
    var images = find('*.png', root: '/images');
    for (var image in images) {
        if (image.startsWith('nsfw')) {
            copy(image, '/keep');
        }
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
You still have full access to the full set of Dart APIs
{% endhint %}

```dart
//  write lines to myfile.ini
var settings = 'myfile.ini';
settings.write('[section1]');
settings.append('color=red');
settings.append('color=blue');

// fix the spelling in myfile.ini
replace(settings, 'color', 'colour');
```

## Call command line apps

A core feature of DCli is the ability to call other CLI apps and process their output.

* run
* start
* toList
* forEach
* firstLine
* lastLine
* \| (pipe)
* stream

Run mysql with all output being displayed to the console.

```dart
var user = ask('username');
var password = ask('password', hidden:true);
'mysql -u $user --password=$password customerdb -e "select 1"'.run;
```

Run a mysql command and store the results in a list (users).

```dart
var users = 'mysql customerdb -e "select fname, sname from user"'
    .toList(skipLines: 1);
/// now parse each user and print their name
for (var user in users) {
    var parts = user.split(',');
    print('Firstname: ${parts[0]} Surname: ${parts[1]});
}
/// Run grep and print each line that it finds
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
DartScript.current;
DartSdk().pathToDartExe;
PubCache().pathTo
```

{% hint style="info" %}
You can explore the complete API [here](https://pub.dev/documentation/dcli/latest/).
{% endhint %}
