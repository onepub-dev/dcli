# Dart lambda functions

This section provides details on the Dart language:

To learn more about Dart's syntax read the Dart language tour. [https://dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour)

DCli makes extensive use of Dart's lambdas.

Lambdas are essentially anonymous functions which DCli uses for callbacks.

The most common use of lambdas in DCli are in the forEach method.

In prior examples you have already seen the forEach method in action.

```dart
'tail tmp/nonexistant.txt'.forEach((line) => print(line));
```

The signature of the forEach method is:

```dart
void forEach(LineAction stdout, {LineAction stderr});
```

The first argument `stdout` of the forEach method is a 'positional' argument, the second argument `stderr` is a named argument. The `stdout` argument is required whilst the `stderr` argument is optional.

`LineAction` is a Dart `typedef` that declares that LineAction is a function that takes a single String.

`typedef LineAction = void Function(String line);`

Essentially this means that forEach expects you to pass a function to the first positional argument `stdout` and optionally the second argument `stderr`.

The functions that you pass are unnamed or anonymous functions known as a Lambda.

The following code uses the \[stdout\] positional argument to print each line returned by the call to the Linux 'tail' command.

```dart
'tail tmp/nonexistant.txt'.forEach(
    (line) => print(line)
    );
```

The 2nd line is the Lambda function that you provide.

Lets break this down.

The line consists of three components

`(line) => print(line)`

Which can be abstracted to:

`(<args>) => <expression>`

In our example the `stdout` positional argument is of type `LineAction`. The `LineAction` function takes a String as its only argument. So in this case `(<args>)` is a single argument of type String.

What this means is that the `forEach` method will call the Lambda function each time the `tail` command outputs a line. The value of that line will be contained in the `line` argument passed to your Lambda.

The second component is the `=>` operator, sometimes referred to as a 'fat arrow'. Essentially the `=>` operator passes the `line` argument to the `<expression>`;

The third and final component is the `<expression>`.

The `<expression>` can be any valid Dart expression. In the above example the expression is `print(line)` which prints the contents of `line` to the console.

One limitation of the `<expression>` is that it must be a single line expression. Our `LineAction` is declared as returning a void so in our case the return value of the expression is ignored.

Dart's Lambdas actually take two forms; the above 'fat arrow' form and a 'block form'.

The block form allows you to execute multiple statements and requires you to use a `return` statement if you want to return something from the Lambda.

The syntax of the Lambda block form is:

`(args) { <statements> }`

Look carefully and note that the block form doesn't have the 'fat arrow'. I've often been caught when converting a 'fat arrow' form to the block form leaving the 'fat arrow' in place; that just doesn't work.

Block form example of a Lambda:

```dart
'tail tmp/nonexistant.txt'.forEach(
    (line) {
         String trimmed = line.trim();
         print(trimmed);

         // If LineAction took a non-void return type then we could use 
         // a return statement here
         // return 'some value';
    }
);
```

Have a look a the next section of named arguments to understand how to process `stderr` when interacting with the `forEach` method.

