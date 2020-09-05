# The evils of CD

## CD/pushd/popd are evil

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

The cd, pushd and popd commands of Bash seem like fun but they are actually harbingers of evil.

I know that they are used everywhere and they seem such an elegant solution but in a script they just shouldn't be used.

So if you shouldn't use cd, pushd or popd what should you do instead?

There a three basic techniques you will use:

* absolute paths
* use the 'start\(\)' method with a working directory
* relative paths

DCli automatically injects the rather excellent package ['path'](https://pub.dev/packages/path) which includes an array of global functions that allow you to build and manipulate file paths to create relative and absolute paths.

You should prefer absolute paths over relative paths.

Such as:

```dart
String filePath = join(HOME, 'directory', 'file.txt');

String dartPath = join('/', 'usr', 'lib', 'bin', 'dart');

// absolute path to your current working directory.
String current = absolute('.');

// create a safe path by replacing the segments (..) with the real path.
String safe = canonicalize(join('..', '..', 'hacker'));

String dirname = dirname(join('usr', 'lib', 'fred.text'));
assert(dirname == '/usr/lib');
```

Often when running an application you need to set the working directory to run the command in.

The following examples runs the command 'git status' from the working directory

/home/yourhome/dev/myproject.

```dart
// run a command using a specific working directory
'git status'.start(workingDirectory: join(HOME, 'dev', 'myproject'));

`
```

With the `path` package at your disposal there is really no need to use cd, pushd or popd.

### Why is cd dangerous?

There are several reasons.

1\) Dart is multi-threaded

> This probably won't be an issue for you as DCli will NEVER start an Isolate and most scripts don't need to use Isolates, but best pratices says that you should assume that one day you might just need to use one, so read on...
>
> Dart and consequently DCli allow you to run multiple threads of execution via Isolates.
>
> The problem is that all of these Isolates running in your Dart process share a single common working directory \(CWD or PWD\).
>
> This means that if you use CD in one isolate, then all other isolates have their working directory changed under their feet.
>
> Imagine if you are about to do a recusive delete in one isolate and some other Isolate changes the working directory to `/`.
>
> Oops you just deleted your entire file system.

2\) A function forgets to pop

> What happens if you call a function that happens to change the working directory?
>
> Again you can end up deleting your entire file system if the function changes to `/`.
>
> 3\) Another process deletes your working directory What happens if another process deletes your working directory just as you are about to delete all of its contents? If you are using the 'paths' package then it will climb the path until it finds a directory that exists and set that as you new working directory. Your new working directory could well be the root directory.

The correct answer is simply don't use CD/PUSH/POP.

Use relative or preferably absolute paths.

