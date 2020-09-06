# DCli Clean

## DCli clean

If you change the structure of your DCli script project then you need to run `dcli clean` so that DCli sees the changes you have made.

What constitutes a structural changes?

* adding an `@pubspec` annotation to your DCli script
* creating a `pubspec.yaml` file in your scripts directory.
* editing an existing `pubspec.yaml`
* editing an existing `@pubspec` annotation

What doesn't constitute a structural change?

* editing your DCli script

If you make a structure change simply call

```text
dcli clean <scriptname.dart>
```

Your script is now ready to run.

You may specify one or more scripts then dcli will clean each of them.

```text
dcli clean hello.dart welcom.dart
```

If you don't specify any scripts then dcli will clean all scripts in the current directory.

