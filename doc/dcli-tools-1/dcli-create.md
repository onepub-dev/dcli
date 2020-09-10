# DCli Create

The `dcli create` command makes it easier to create new scripts.

The `dcli create` command create a sample DCli script using the given script file name and initialise your project by running `dcli clean`.

dcli create performs the following actions:

* creates &lt;script.dart&gt;
* creates pubspec.yaml
* creates analysis\_options.yaml
* marks your script as executable
* adds a shebang \#! to the start of your script.
* runs `dcli clean` in the background.

{% hint style="info" %}
dcli create won't create the pubspec.yaml nor analysis\_options.yaml if you create your new script in an existing dart project.
{% endhint %}

Usage: `dcli create <script.dart>`

Example:

```text
dcli create my_script.dart
Creating project.
DCli clean started in the background.

To run your script:
  ./my_script.dart
```

As the sample script has a Shebang \#! added you can execute it directly:

```text
./my_script.dart
```

{% hint style="info" %}
If you run you script immediately after creating it, the background 'clean' may still be running.
{% endhint %}

In which case you may see the message:

```text
./test.dart
Waiting for clean to complete...
Hello World
```

The clean process is a once off process and only needs to be run again if you change your dependencies.

The first time you run a given DCli script \(created with dcli create\), DCli needs to resolve any dependencies by running a Dart `pub get` command and doing some other house keeping.

If you run the same script a second time DCli has already resolved the dependencies and so it can run the script immediately.

## Flags

The dcli create command accepts the following flags:

-- foreground :

If the foreground flag is passed the dcli clean process will be ran in the foreground rather than the use background execution.

Now lets create and run our first DCli script.

