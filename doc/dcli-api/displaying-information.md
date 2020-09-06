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

### Format.row

This method is considered experimental. Use at your own peril.

The row method allows you to output a row of fixed with columns with controlled alignment.

```text
print(Format.row(['OS Version', '${Platform.operatingSystemVersion}'],
        widths: [17, -1]));
```

Outputs a row with two columns. The first is 17 characters wide, the second expands as needed.

```text
print(Format.row([
          '$label',
          '${fstat.modeString()}',
          '<user>:${(owner.group == owner.user ? '<user>' : owner.group)}',
          '${privatePath(path)} '
        ], widths: [
          17,
          9,
          16,
          -1
        ], alignments: [
          TableAlignment.left,
          TableAlignment.left,
          TableAlignment.middle,
          TableAlignment.left
        ]));
```

Outputs a row with four columns of widths 17, 9, 16 and infinite. The columns are aligned, left, right, middle and left.

### clearScreen

Clears the console.

```text
clearScreen();
```

### clearLine

Clears the current line.

```text
clearLine();
```

### startOfLine

Moves the cursor to the start of the current line.

```text
startOfLine;
```

### previousLine

Moves the cursor to the start of the previous line.

### showCursor

Shows or hides the cursor.

```text
showCursor(show: true);
```

### column

Moves the cursor to the given column on the current line.

