# Pubspec Managment

## Pubspec Management

The `pubspec.yaml` file is Dart's equivalent of a `makefile`, `pom.xml`, `build.gradle` or `package.json`.

You can see additional details on Dart's pubspec here:

[https://dart.dev/tools/pub/pubspec](https://dart.dev/tools/pub/pubspec)

### How we locate your pubspec

Its important to understand that DCli follows the same rules as dart does for locating a pubspec.yaml, with a few additions.

By following the same rules as dart does DCli makes it possible for DCli scripts to work seamless with your current development tools.

Dart and DCli will look for a pubspec.yaml in the scripts directory and then check each parent directory up to the root of the file system for pubspec.yaml. The first one that we find will be used.

### Default Pubspec

If you create you script using dcli create then it will create a default pubpsec.yaml for you with the following dependencies:

```yaml
dependencies:
  dcli: ^0.25.0
  args: ^1.0.0
  path: ^1.0.0
```

You can changed the default set of dependencies by editing ~/.dcli/pubspec.yaml.

The default dependencies are:

* dcli
* [path](https://pub.dev/packages/path)
* [args](https://pub.dev/packages/args)

The above packages provide your script with a swiss army collection of tools that we think will make your life easier when writing DCli scripts.

The 'path' package provide tooling for building and manipulating directory paths as strings.

The 'args' package makes it easy to process command line arguments including adding flags and options to your DCli script.

