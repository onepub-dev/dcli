# Paths

Generating file paths can be a tedious task and error prone if you want your paths to be cross platform.

Fortunately there is a solution at hand.

The good folk a Google have created the [paths](https://pub.dev/packages/path) package for our use.

The paths package includes a number of global functions that let us create and manipulate file paths.

* join
* dirname
* extension
* basename
* basenameWithoutExtension
* truepath

The path package is included as part of DCli so you don't need to add a dependency to your pubspec.yaml.

For a full list of the available functions please refer to the path [API](https://pub.dev/documentation/path/latest/).

## Join

The join function is probably the most used path function. It combines components of a path into a single path.

The best way to understand it is via some examples.

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
```

'rootPath' is a DCli property that is the root directory for your OS. On Linux and OSX this is '/' on Windows this is '\';

```dart
var apps = join(HOME, 'apps');
var tmp = join(apps, 'which.dart');
print(tmp);
> /home/me/which.dart
```

{% hint style="info" %}
HOME is a DCli property which returns the value of the environment variable 'HOME' \(in this example /home/me\)
{% endhint %}

In the above example we can see that the join path combines two path fragments to form a complete path.

## Dirname

The dirname function returns the directory path of a file path:

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
print(dirname(tmp));
> /tmp/abc
```

The dirname function will also strip the last directory of a path is the passed path doesnt' have a filename.

```dart
var tmp = join(rootPath, 'tmp', 'abc');
print(tmp);
> /tmp/abc
print(dirname(tmp));
> /tmp
```

The dirname function is often used to traverse up a directory tree.

```dart
var tmp = join(rootPath, 'tmp', 'abc');
while (tmp != rootPath) {
    print(tmp);
    tmp = dirname(tmp);
}
print(tmp);

> /tmp/abc
> /tmp
> /
```

## Extension

The extension function returns the extension of a file.

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
print(extension(tmp));
> txt
```

## Basename

The basename function returns the filename.

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
print(basename(tmp));
> image.txt
```

basenameWithoutExtension

The basenameWithoutExtension function turns the filename without the extension.

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
print(basenameWithoutExtension(tmp));
> image
```

## truepath

Truepath is s DCli function rather than a 'path' function.

The truepath combines a number of 'path' functions to return an absolute path that has been canonicalised.

{% hint style="info" %}
A canonical path is one which has had the '..' components resolved.
{% endhint %}

A common mistake made by many cli applications when reporting errors is to report relative paths.

For the user of your application it can often be difficult to determine what the relative path is relative to. All DCli errors that contain a path call truepath so that the path is absolute and canonicalised, this gives your users the best chance of correctly identifying the file or path that caused the problem.

You should also canonicalise any path that a user enters. Using '..' to bypass security checks is a common hacking trick.

