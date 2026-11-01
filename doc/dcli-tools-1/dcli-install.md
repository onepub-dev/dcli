# DCli Install

## install

The install command MUST be run after you activate dcli to complete the dcli install.

```dart
dart pub global activate dcli
dcli install
```

The `dcli install` command creates the `~/.dcli` directory, expands the DCli templates and adds `~/.dcli/bin` to your PATH for the current user.

You will need to restart your terminal after the install completes for your paths to update correctly.

To install a compiled command for every user, use [`dcli compile --system`](dcli-compile.md#install-a-compiled-script-for-all-users). This is separate from installing DCli itself.

