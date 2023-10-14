# Function Arguments

This section provides details on the Dart language:

To learn more about Dart's syntax read the Dart language tour. [https://dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour)

Dart allows three types of arguments to be passed to a method or function.

Positional, optional and named.

Positional arguments are traditional 'C' style arguments that everyone is familiar with.

Optional arguments are positional arguments that are (you guessed it) optional.

Named arguments are a little trickier but depending on your current language experience you may already be familiar with them.

Named arguments allow you to pass an argument by name rather than position and they are (usually) optional.

To declare a named argument you use curly braces `{}`.

```dart
void testMethod(String arg1, [String arg2], {String? arg3, String? arg4});
```

In the above example `arg1` is a positional argument, `arg2` is an optional argument with `arg3` and `arg4` being optional named arguments.

To call the test method passing values to all of the above arguments you would use:

```dart
testMethod('value1', 'value2' , arg4: 'value4', arg3: 'value3');
```

Note that I've reversed the order of `arg3` and `arg4`. As they are named arguments you can place them in any position AFTER the named and optional arguments.

Let's finish with an example using the forEach method:

```dart
'tail /var/log/syslog'.forEach((line) => print(line), stderr:(line) => print(line));
```

The above example will print any output sent to stdout or stderr from the 'tail' command.
