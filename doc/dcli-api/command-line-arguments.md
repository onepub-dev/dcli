# Command Line Arguments

A command line app is only so useful unless you can pass arguments to your app.

Like many languages Dart allows you to pass arguments to your main method..

```dart
void main(List<String> args)
{
    print('Found ${arg.length} arguments.');
    
    print('The arguments are:');

    for (int i = 0; i < args.lenght; i++) {
        print('arg[$i]=${args[i]}');
    }
}
```

If you DCli script is called test.dart:

```text
dart test.dart one two three
> Found 3 arguments.
> The arguments are:
> arg[0] = one
> arg[1] = two
> arg[2] = three
```

You can also stop the your app and return an exit code using the exit method.

```dart
import 'dart:io';

void main(List<String> args)
{
    print('Found ${arg.length} arguments.');
    
    /// stops the progam so no further lines will be executed.
    /// The progam outputs an exit code of 1.
    exit(1);
    
    print('The arguments are:');

    for (int i = 0; i < args.lenght; i++) {
        print('arg[$i]=${args[i]}');
    }
}
```

### ArgParser

For simple command argument processing you can process the args argument yourself. 

If you want to do more complex argument processing then its better to get some help.

The Dart team has very kindly put together the [args](https://pub.dev/packages/args) package which provides advanced argument parsing.  The DCli API includes the args package so you do NOT need to added it to your pubspec.yaml dependencies.

You can read all about using the [args](https://pub.dev/packages/args) package on [pub.dev](https://pub.dev/packages/args) but here is a little example of what you can do:

```dart
import 'dart:io';
import 'package:dcli/dcli.dart';

/// This is a full implementation of the linux cli 'which' app.
/// The which command searches the PATH for the passed exe.
void main(List<String> args) {
  
  /// create the parser and add a --verbose option
  var parser = ArgParser();
  parser..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false);

  /// parse the passed in command line arguments.
  var results = parser.parse(args);
  
  /// get the value of the passed in verbose flag.
  var verbose = results['verbose'] as bool;

  /// The 'rest' of the results are any additional arguments
  /// we only expect one which is the name of the exe we are looking for.
  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  /// name of the command we will search for.
  var command = results.rest[0];
  var home = env['HOME'];

  List<String> paths;
  paths = env['PATH'].split(':');

  for (var path in paths) {
    if (path.startsWith('~')) {
      path = path.replaceAll('~', home);
    }
    if (verbose) {
      print('Searching: ${canonicalize(path)}');
    }
    if (exists(join(path, command))) {
      print(red('Found at: ${canonicalize(join(path, command))}'));
    }
  }
}

```

To use the above application:

```dart
dart which.dart ls
Found at: /usr/bin/ls
Found at: /bin/ls

```



