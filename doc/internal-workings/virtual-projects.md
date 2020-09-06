# Virtual Projects

## Virtual Projects

A normal Dart program requires a certain directory structure to work:

```text
hello_world.dart
pubspec.yaml
lib/util.dart
```

The aim of DCli is to remove the normal requirements so we can run a single Dart script while still allowing you to gracefully grow your little project to a full blow application without having to start over.

Virtual Projects are where this magic happens.

DCli creates a configuration directory in you home directory:

```text
~/.dcli
~/.dcli/templates
~/.dcli/dependancies.yaml
~/.dcli/cache
```

When you run a DCli script, DCli creates a Virtual Project under the `cache` directory using the fully qualified path to you script.

So if you have a script:

```text
/home/fred/myscripts/hello_world.dart
```

then DCli will create a Virtual Project under the path

```text
~/.dcli/cache/home/fred/myscripts/hello_world.project
```

Using the fully qualified path allows multiple scripts to exist in the same directory and we can still run a Virtual Project for each script.

Within the Virtual Project directory DCli creates all the necessary files and directories need to make Dart happy

So a typical Virtual Project will contain:

```text
symlink -> hello_world.dart
pubspec.yaml
```

The pubspec.yaml is referred to as your `virtual pubspec` and is created as per the [pubspec precendence](../#Pubspec-Precendence) rules and the [dependency injection](../#Pubspec-dependancy-injection) rules.

If you script directory contains a `lib` folder then we create:

```text
symlink -> /home/fred/myscripts/hello_world.dart
pubspec.yaml
symlink -> /home/fred/myscripts/lib
```

The first time you run a DCli script and when you perform a `dcli clean` DCli recreates your pubspec.yaml, rebuilds your Virtual Project and runs `pub get`.

