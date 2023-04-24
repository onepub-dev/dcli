# Environment variables

## Environment Variables

DCli provides tools to manage the environment variables within your DCli script and any child process you call from a DCli script.

{% hint style="info" %}
For complete API documentation refer to: [pub.dev](https://pub.dev/documentation/dcli/latest/dcli/dcli-library.html)
{% endhint %}

When a DCli script starts, it loads the set of environment variables from its parent process (usually your shell). The full set of environment variables are available via the `envs` function which returns a map containing key/value pairs for all environment variables.

To access an environment variable called 'COLORTERM':

```dart
var colorTermValue = env['COLORTERM'];
```

You can also set an environment variable:

```dart
env['DART_SDK'] = 'somepath';
```

Once you create or modify an environment variable, then any calls to `env[]` will return the modified value.

If you run a child process via any of the DCli methods then the child process will be passed all of current environment variable.

{% hint style="warning" %}
You CANNOT change the parent shell's environment variables. This is a security restriction imposed by the OS.
{% endhint %}

DCli also exposes a number of commonly used environment variables as global getters.

* HOME - your home directory
* PATH - a list of all the paths that make up your PATH.
* pwd - the present working directory.

```
// home will contain the path to your HOME directory.
var home = HOME;

/// paths will contain a list of the paths contain in your OS PATH environment variable.
List<String> paths = PATH;

paths.forEach((path) => print(path));

print('Your working directory is $pwd);
```

### envs -> Map\<String, String>

Returns a map of all the environment variables inherited from the parent as well as any changes made by calls to \`env\[]=\`.

### PATH

DCli provides a list of methods allow you to modify the PATH. Like any environment variables modifying the PATH will only affect child process you call and not the parent shell.

Methods to manipulate the path include:

* appendToPATH
* prependToPATH
* removeFromPATH
* isOnPATH
* delimiterForPATH

### withEnvironment

The `withEnvironment` function allows you to modify environment variables within the scope of a call.

This can be used to configure a set of environment variables when you run a process that has specific requirements or simply nested code that uses environment variables.

It is particularly useful when writing unit tests as you can set alternate environment variables for each unit test.

```dart
 withEnvironment(() {
     /// run some command with an latered HOME environment variable
     /// any functions called from directly or indirectly from here
     /// will see this scoped environment.
    }, environment: {'HOME': testDir});
```

The `environment` argument is merged with the existing `env` map. Any environment variables passed in via `environment` will replace existing keys in `env`.

No other code will see the modified `env`.
