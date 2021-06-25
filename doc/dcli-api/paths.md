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
* truepath - this is actually a DCli provided method.
* canonicalize

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

'rootPath' is a DCli property that is the root directory for your OS. On Linux and Mac OS this is '/', on Windows this is 'C:\' \(dependent on your current working directory\).

```dart
var apps = join(HOME, 'apps');
var tmp = join(apps, 'which.dart');
print(tmp);
> /home/me/which.dart
```

{% hint style="info" %}
HOME is a DCli property which returns the value of the environment variable 'HOME' \(in this example /home/me\)
{% endhint %}

In the above example we can see that the join function combines two path fragments to form a complete path.

## Dirname

The dirname function returns the directory path of a file path:

```dart
var tmp = join(rootPath, 'tmp', 'abc', 'image.txt');
print(tmp);
> /tmp/abc/image.txt
print(dirname(tmp));
> /tmp/abc
```

The dirname function will also strip the last directory of a path is the passed path doesn't have a filename.

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

The truepath combines a number of 'path' functions to return an absolute path that has been normalised.

{% hint style="info" %}
A normalised path is one which has had the '..' components resolved.
{% endhint %}

A common mistake made by many CLI applications when reporting errors is to report relative paths.

```dart
/// if you pwd is /usr/home
truepath('adirectory') == '/usr/home/adirectory';
truepath('..', 'adirectory') == '/usr/adirectory';
truepath(rootPath, 'usr', 'home', 'adirectory') == '/usr/home/adirectory';

// on windows
truepath(rootPath, 'usr', 'home', 'adirectory') == 'C:\usr\home\adirectory';

```

For the user of your application it can often be difficult to determine what the relative path is relative to. All DCli errors that contain a path call truepath so that the path is absolute and normalised, this gives your users the best chance of correctly identifying the file or path that caused the problem.

You should also normalised any path that a user enters. Using '..' to bypass security checks is a common hacking trick.

## **canonicalize**

If you need to compare to paths you need to both canonicalize your path. As Windows paths are case-insensitive the canonicalize operations returns a all lowercase version of the path which ensures to equivalent paths will return true when a string comparison is performed. The call to canonicalize will also normalize the path.

The only safe way to compare two paths it to compare two absolute paths that have been canonicalized:

```dart
canonicalize(absolute('adirectory')) == '/current/dir/adirectory';
```

The `absolute` call assumes that `adirectory` is in the current working directory. To get the absolute path of a directory relative to some other directory use `relative`.

```dart
canonicalize(relative('adirectory', from: '/home/me')) == '/home/me/adirectory';
```

