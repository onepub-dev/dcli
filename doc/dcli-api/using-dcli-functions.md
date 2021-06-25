# Using DCli functions

## Using DCli functions

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

Lets start by looking at the some of the built in functions that DCli supports.

DCli exposes a range of built-in functions that are exposed as Dart global functions.

These functions are the core of how DCli provides a very Bash like feel to writing DCli scripts.

These functions make strong use of named arguments with intelligent defaults so mostly you can use the minimal form of the function.

Take note, there are no `Futures` or `await`s here. Each function runs synchronously.

```dart
import 'package:dcli/dcli.dart';

void main() {
    // Use the global DCli Settings to enable debug output.
    Settings().setVerbose(enabled: true);

    // Print the current working directory
    print('PWD: ${pwd}');

    // Create a directory and if necessary
    // its parent directories.
    var pathToImages = 'tools/images';
    createDir(pathToImages, recursive: true);

  
    var pathToGoodJpg = join(pathToImages, 'good.jpg');
    // create a file (its empty)
    touch(pathToGoodJpg, create: true);

    // update the last modified time on an existing file
    touch(pathToGoodJpg);

    print('Showing all files');

    // print out all files in the current directory.
    // [file] is just a [String]
    find('*.*', recursive: false).forEach((file) => print(file));

    // take a nap for a couple of seconds.
    sleep(2);

    print('Find file matching *.jpg');
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find('*.jpg', workingDirectory: pathToImages).toList()) {
        print(file);
    }

    var pathToBadJpg = join(pathToImages, "bad.jpg");
    // Move/rename a file
    move(pathToGoodJpg, pathToBadJpg);

    // check if a file exists.
    if (exists(pathToBadJpg)) {
        print("bad.jpg exists");
    }

    // Delete a file asking the user first.
    delete(pathToBadJpg, ask: true);

}
```

As you can see we have achieved much of the power of Bash without any of the ugly grammar, and what's more we only used one type of quote!

