# Displaying information

DCli provides a number of methods to display information to a user:

### print

Dart provides the built in function 'print' which prints a line of text including a new line.

```text
print('hello world');
```

### printerr 

The standard Dart 'print' function prints to stdout, DCli's 'printerr' function is identical except that it prints to stderr.

```text
printerr('something bad happened.');
```

You should use printerr when you are printing error messages.

### echo

The echo function is provided to supplement the Dart print method. The 'echo' allows you to control whether a new line is output after the text. By default echo will NOT output a newline.

```text
echo('hello', newline: false);
```

### Colour coding

DCli allows you colour code your ouput.

```text
print(orange('hello world'));
```

You can also control the background colour:

```text
print(orange('hello world'), bgcolor: AnsiColor.black);
```

The following colours are supported for both the foreground \(text\) and background colours.

You can also set the background color to the default by passing 

* red
* black
* green
* blue
* yellow
* magenta
* cyan
* white
* orange
* grey

- prints to stderr.

* colour coding
* cursor management
* clear screen/clear line

