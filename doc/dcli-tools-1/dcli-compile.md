# DCli Compile

The compile command will compile your DCli script(s) into a native executable and optionally install it into your PATH.

The resulting native application can be copied to any binary compatible OS and run without requiring Dart or DCli to be installed.

Dart complied applications are also super fast.

Usage: `dcli compile [-nc, -i, -o] [<script path.dart>, <script path.dart>,...]`

Example:

{% tabs %}
{% tab title="Linux" %}
```bash
dcli compile hello_world.dart

./hello_world
```
{% endtab %}

{% tab title="OSx" %}
```
dcli compile hello_world.dart

./hello_world
```
{% endtab %}

{% tab title="Windows" %}
```
dcli compile hello_world.dart

hello_world.exe
```
{% endtab %}
{% endtabs %}

You may specify one or more scripts and DCli will compile each of them.

If you don't specify any scripts then DCli will compile all scripts in the current directory.

If you use the --install option the compiled exe will be added to your path.

{% hint style="info" %}
DCli copies the executable into \~/.dcli/bin which is added to your path when you run dcli install.
{% endhint %}

{% tabs %}
{% tab title="Linux" %}
```bash
dcli compile --install hello_world.dart

hello_world
```
{% endtab %}
{% endtabs %}

## Compile a package

DCli can also compile a globally activated package.

```bash
dart pub global activate critical_test
dcli compile --package critical_test
critical_test
```

Compiling a globally activated package has a number of uses:

* faster startup time
* you are able to copy the resulting executable to any binary compatible machine and run it without installing Dart
* If you switch Dart versions then the executable will still run even if the package isn't compatible with the installed Dart version. This can be useful if you need to run an old version of dart but want access to the latest version of a Dart CLI package.

## Flags:

### --noprepare | -nc :

stop DCli from running prepare before doing a compile. Use this option if you know that you script's dependencies haven't changed since the last compile resulting in a faster compile.

### --install | -i :

install the compiled script into the \~/.dcli/bin directory which is on your path. -

### --overwrite | -o :

if the target script has already been compiled and installed, you must specify the -o flag to allow DCli to overwrite it.

### --package | -p

compiles a globally activated package and installs it into the !/.dcli/bin directory.
