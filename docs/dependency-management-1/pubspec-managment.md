# Pubspec Managment

## Pubspec Management

The `pubspec.yaml` file is Dart's equivalent of a `makefile`, `pom.xml`, `build.gradle` or `package.json`.

You can see additional details on Dart's pubspec here:

[https://dart.dev/tools/pub/pubspec](https://dart.dev/tools/pub/pubspec)

DCli aims to make creating a script as simple as possible and with that in mind we provide a number of ways of creating and managing your pubspec.yaml.

By default you do NOT need a pubspec.yaml when using DCli but its generally easier if you do create one as your dev tools \(vscode android studio\) expect to find one.

NOTE: if you change the structure of your DCli script you need to run a `dcli clean`. Simple edits to you DCli script do NOT require a `clean` to be run.

### Supported pubspec locations

DCli allows you to place your pubspec in the following locations:

* Standard pubspec.yaml - you use the standard dart package structure with the pubspec.yaml in the root of your project.
* Local pubspec - you place a pubspec.yaml file in the same directory as your script.
* No pubspec - we create a virtual pubspec for you.
* @pubspec annotation - the pubspec lives in your script in the form of an annotation.

### How we locate your pubspec

Its important to understand that DCli follows the same rules as dart does for locating a pubspec.yaml, with a few additions.

By following the same rules as dart does DCli makes it possible for DCli scripts to work seamless with your current development tools.

There are some exceptions.

### No pubspec

If DCli doesn't find a pubspec then it will automatically create a default pubspec.yaml for you. The default pubspec.yaml is stored in the script's Virtual Project cache \(under `~/.dcli/cache/<path_to_script>.project`\).

We refer to this as a 'virtual pubspec'.

When you first launch your script or when running `dcli clean <scriptname.dart>` DCli creates/recreates your `virtual pubspec`.

Whether you use a virtual pubspec or create your own, DCli performs dependancy injection \([see dependancy injection](../#Pubspec-dependancy-injection)\) providing a common set of packages that together create a 'swiss army knife' of useful tools to use when developing DCli scripts.

### Explicitly defining a pubspec

If you find that you need additional dependencies or other controls that an explict pubspec provides, then you may need to create your own pubspec.

DCli provides two ways to do this.

* an inline pubspec using DCli's `@pubspec` annotation.
* a classic Dart pubspec.yaml with all the normal features.

The DCli `@pubspec` annotation allows you to retain the concept of a single script so you can copy your DCli script anywhere and it will just work.

Using the `@pubspec` annotation also means that you can have many DCli scripts living in the same directory each with their own pubspec. If you use a classic pubspec.yaml then all your scripts, in that directory, will be sharing the same pubspec \(which isn't necessarily a bad thing\).

See the section on [PubSpec precedence](../#Pubspec-Precendence) for details on how DCli works if you mix pubspec annotations and a pubspec.yaml in the same directory.

For simple scripts you will normally use the `@pubspec` annotation but as your script grows you may want to migrate to a separate `pubspec.yaml`.

DCli has a tool to make this easier.

Run:

```text
dcli split <scriptname.dart>
```

If your script `<scriptname.dart>` contains a `@pubspec` annotation then DCli will remove it from your script and create a classic `pubspec.yaml` file in the directory along side your script.

### Pubspec dependency injection

When DCli creates your virtual pubspec, on first run or after a clean,it will inject a default set of dependencies into your pubspec.

Dependency injects occurs when you don't provide a pubspec.yaml or when you use the `@pubspec` annotation.

If you created a classic `pubspec.yaml` then DCli will NOT perform dependencies injection.

DCli stores the default dependencies in:

`~/.dcli/dependencies.yaml`

The syntax of `dependancies.yaml` is idential to the standard `pubspec.yaml` dependancies section.

Example:

```yaml
dependencies:
  dcli: ^0.20.0
  args: ^1.5.2
  path: ^1.6.4
```

`dependencies.yaml` supports all of the standard dependency sources such as git and path.

DCli also supports the dependencies\_override section if required.

See \[[https://dart.dev/tools/pub/dependencies](https://dart.dev/tools/pub/dependencies)\] for more details on dependencies and dependency sources.

If you find a really nice package that you use time and again then its easier to add it to the set of default dependencies than having to add it to every script.

Feel free to modify the set of dependencies that DCli ships with. The only one you really need is the DCli package \(but you can even remove that if you don't like the standard DCli library\).

The default dependencies are:

* dcli
* [path](https://pub.dev/packages/path)
* [args](https://pub.dev/packages/args)

The above packages provide your script with a swiss army collection of tools that we think will make your life easier when writing DCli scripts.

The 'path' package provide tooling for building and manipulating directory paths as strings.

The 'args' package makes it easy to process command line arguments including adding flags and options to your DCli script.

### Overriding default dependency

DCli provides a nice set of basic tools \(packages\) for your DCli scripts and you can add more in your script's pubspec.

Sometimes you may find that a script needs a specific version of a default dependency. DCli allows you override a default dependencies version on a per script basis.

If you have declared any of the default packages in the dependencies section of you `@pubspec` annotation then the version you declare will be used instead of the default version.

If you provide an actually `pubspec.yaml` in your script directory then DCli does NOT perform dependency injection.

NOTE: you must run 'dcli cleanall' if you modify your 'dependancies.yaml' as DCli doesn't check this file for changes.

### Pubspec precedence

DCli allows you to define your pubspec either via a `@pubspec` annotation within your script or a classic `pubspec.yaml` which lives in the same directory as your script.

DCli also support the concept of allowing multiple single file DCli scripts to exist in the same directory.

This has the potential to create ambiguities as to which pubspec definition is to be used.

To remove the ambiguities these pubspec rules are used and applied in the following order: 1\) If the script contains an `@pubspec` annotation use it. 2\) If the scripts directory contains a `pubspec.yaml` use it. 3\) If 1\) and 2\) fail then create a default virtual pubspec definition.

So what happens if you have multiple DCli scripts in a single directory and a classic pubspec.yaml file?

```text
cli> ls
hello_world.art
find_me.dart
pubsec.yaml
cli>
```

Well according to the rules, if a DCli script has an `@pubspec` annotation then that will be used and the classic `pubspec.yaml` file will be ignored.

If your DCli script doesn't have an `@pubspec` annotation then the `pubspec.yaml` file will be used.

This means that multiple DCli scripts can share the same `pubspec.yaml` which could be convenient at times.

So a word of caution.

If you have an existing DCli script which relies on DCli's 'virtual pubpsec' \(i.e. it doesn't have an `@pubspec` annotation\) and you copy the script into a directory that has an existing `pubspec.yaml` then the next time you run your script from its new home it will use the adjacent `pubspec.yaml`.

### Pubspec Annotation

The `@pubspec` annotation allows you to specify your pubspec definition right inside your DCli script.

Using an `@pubspec` annotation allows you to retain the concept of a single independent script file. This has the advantage that you can copy your DCli script file anywhere and just run it \(provided DCli is installed\).

To add a `@pubspec` annotation to your file add the `@pubspec` annotation within a `/* */` comment and follow the standard rules for formatting a `pubspec.yaml` file.

Remember, yaml is fussy about the right level of indentation!

```dart
#! /usr/bin/env dcli

/*
@pubspec.yaml
name: tryme
dependencies:
  money2: ^1.0.3
*/

import 'package:dcli/dcli.dart';
import 'package:money2/money2.dart';

void main()
{
    Currency aud = Currency.create("AUD", 2);
    Money notMuch = Money.parse("\$2.50", aud);

    echo("Hello World");
    echo("All I have is ${notMuch}");
}
```

If your `@pubspec` annotation gets large, you might want to split the annotation out to a classic `pubspec.yaml` file. To do this you can use the DCli split command.

```text
dcli split <script filename>
```

Once the `split` command completes you will have a newly created `pubspec.yaml` file and you `@pubspec` annotation will have been removed from your script.

