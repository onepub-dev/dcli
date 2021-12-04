# Implemention support for a shell

DCli provide access to an abstracted interface to a shell's underlying functions through the Shell class.

DCli provides various levels of support for a number of shells including:

* ash
* bash
* cmd
* dash
* fish
* power shell
* sh
* zsh

## Adding support for a shell

Adding basic support for a shell is fairly easy:

1\) copy an existing shell implementation from lib/src/shell

2\) modify the implementation to match your shell's implementation details

3\) register your shell with by adding it to the '_shells' array in lib/src/shell/shell\_detection.dart_

### _Basic Shell support_

To implement the minimal level of shell support you will need to provide implementations for:

* Constructor 'withPid
* name
* hasStartScript
* isCompletionSupported
* hashCode
* operator ==

### Privileged User

On linux we have the concept of sudo and on Windows an Administrator. DCli exposes these concepts as a 'privileged' user.

The Shell.isPrivilegedUser method allows DCli to determine if the current script is running under a privileged user. The libraries posix\_mixin.dart, cmd\_shell.dart and power\_shell.dart all have separate implementations of this. You may be able to use one of these existing implementations but you may need to implement your own.

### Install support

DCli attempts to automate as much of the DCli and dart installation process as possible.

Ideally your shell should support configuring DCli and dart. There are standard implementations for both of these actions that you should normally be able to use.

The platform specific implementation for Windows is in windows\_mixin.dart and for Linux and MacOS in posix mixin.dart.

These mixins should work for any shell so normally your shell should just 'with' the appropriate mixin.

The one exception is support updating the paths for DCli and Dart.

The DCli installer calls Shell.addToPath in order to achieve this.

You will most likely need to implement a custom implementation of Shell.addToPath. Have a look at bashshell.dart and cmd\_shell.dart for example implementations.

### Completion Support

Some shells offer tab completion.

At the time of this writing DCli only supports tab completion for bash.

To implement tab completion for other shells you need to:

Override the lib/src/shell/Shell.dart methods :

* isCompletionSupported
* isCompletionInstalled
* installTabCompletion

You then need to implement a tab completion system for your shell.

For bash DCli ships the executable bin/dcli\_complete.

If your Shell's completion tooling allows/expects the use of an executable to provide the tab completion support you may modify the dcli\_complete.dart library to also provide completion for you shell.

You can use the `Shell.current` method to determine if you shell is being run when the dcli\_complete is executed.
