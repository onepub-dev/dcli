# Writing your first script

Let's start by going over the basic by writing the classic hello world program.

Create a directory to work in:

{% tabs %}
{% tab title="Linux" %}
```bash
mkdir dcli_scripts
cd dcli_scripts
```
{% endtab %}

{% tab title="Windows" %}
```
mkdir dcli_scripts
cd dcli_scripts
```
{% endtab %}

{% tab title="OSx" %}
```
mkdir dcli_scripts
cd dcli_scripts
```
{% endtab %}
{% endtabs %}

Using your preferred editor create a file called 'hello.dart' with following content:

```dart
void main() {
    print('Hello World.');
}
```

### Running

Now lets run your script:

```dart
dart hello.dart
> Hello World.
```

When we run our script using the `dart` command, dart performs JIT compilation of our script which slows down the startup time a little.

### Compiling

You can compile your script to a native executable so that it launches and runs much faster.

```bash
dart2native hello.dart
Generated: hello.exe
./hello.exe
> Hello World

ll hello.exe
-rwxrwxr-x 1 5,875,400 Sep  5 14:30 hello.exe*
```

You now have a completely self contained executable which you can copy to any binary compatible machine.

The exe is 5MB in size and does NOT require Dart to be installed.

### Dependencies

So far we haven't actually used the DCli API in our hello.dart program. Lets now setup dependency management so we can use the DCli API and any other Dart package.

Dart uses a special file called `pubspec.yaml` to control the set of packages accessible to your application.

Dart's pubspec.yaml is equivalent to a makefile, pom.xml, gradle.build or package.json in that it defines the set of dependencies for you application.

To use DCli or any other Dart package you need to added the dependency to your pubspec.yaml.

Create and edit your first pubspec.yaml:

```bash
name: hello_world
description: My first app that does bugger all.

dependencies:
  dcli: ^0.24.0
```

Whenever you change your pubspec.yaml you must run pub get to download the required dependencies:

```bash
pub get
Resolving dependencies... 
Got dependencies!
```

### Writing a DCli script

Now that we have added DCli to our pubspec.yaml we can now modify hello.dart to make calls to the DCli API.

Edit your hello.dart script as follows:

```bash
import 'package:dcli/dcli.dart';


void main() {
    print('Now lets do someting useful.');

    var username =  ask( 'username:');
    print('username: $username');

    var password = ask( 'password:', hidden: true);
    print('password: $password');

    // create a directory
    if (!exists('tmp')) {
    	createDir('tmp');
    }

    // Truncate any existing content
    // of the file 'tmp/text.txt' and write
    // 'Hello world' to the file.
    'tmp/text.txt'.write('Hello world');

    // append 'My second line' to the file 'tmp/text.txt'.
    'tmp/text.txt'.append('My second line');

    // and another append to the same file.
    'tmp/text.txt'.append('My third line');

    // now copy the file tmp/text.txt to second.txt
    copy('tmp/text.txt', 'tmp/second.txt', overwrite: true);

    // lets dump the file we just created to the console
    read('tmp/second.txt').forEach((line) => print(line));

    // lets prove that both files exist by running
    // a recursive find.
    find('*.txt').forEach((file) => print('Found $file'));

    // Now lets tail the file using the OS tail command.
    // Again using dart 2.6 extensions we treat a string
    // as an OS command and run that command as 
    // a child process.
    // Any stdout and stderr output is written
    // directly to the console.
    'tail tmp/text.txt'.run;

    // Lets do a word count capturing stdout,
    // stderr will will be swallowed.
    'wc tmp/second.txt'.forEach((line) => print('Captured $line'));

    if (confirm( "Should I delete 'tmp'? (y/n):")) {
        // Now lets clean up
        delete('tmp/text.txt');
        delete('tmp/second.txt');
        deleteDir('tmp');
    }

}
```

Now run our script.

```bash
dart hello.dart
Now lets do someting useful.
username: auser
username: auser
password: *********
password: apassword
Hello world
My second line
My third line
Found /tmp/fred/tmp/second.txt
Found /tmp/fred/tmp/text.txt
Hello world
My second line
My third line
Captured  3  8 41 tmp/second.txt
Should I delete 'tmp'? (y/n): (y/n): y
```

You are now officially a DCli guru.

Go forth young man \(or gal\) and create.

