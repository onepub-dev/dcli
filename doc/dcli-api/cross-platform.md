# Cross Platform

Dart and DCli are designed to be cross platform with support for Linux, Mac OS and Windows.

Most of the API's in DCli can be used without consideration for which platform you are running on. There are however a number of issues that you should be aware of.

## Paths

One of the biggest headaches with building cross platform apps is the differences in paths.

Windows uses a drive designator C: and the backslash character \ whilst Linux and OSX use the forward slash /.

Most of the problems around Paths can be avoided by using the [https://pub.dev/packages/path](https://pub.dev/packages/path) package which is included in DCli.

So rather than hard coding a path like:

```dart
var path = '/var/tmp';
```

Use the paths package:

```dart
var path = join(rootPath, 'var', tmp);
```

On Windows `path` will be `C:\var\tmp` assuming that your current drive is the C: drive.

On Linux and Mac OS the `path` will be `/var/tmp`.



