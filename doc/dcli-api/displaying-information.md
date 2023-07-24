# Displaying information

DCli provides a number of methods to display information to a user:

## print

Dart provides the built in function 'print' which prints a line of text including a new line.

```
print('hello world');
```

## printerr

The standard Dart 'print' function prints to stdout, DCli's 'printerr' function is identical except that it prints to stderr.

```
printerr('something bad happened.');
```

You should use printerr when you are printing error messages.

## echo

The echo function is provided to supplement the Dart print method. The 'echo' allows you to control whether a new line is output after the text. By default echo will NOT output a newline.

```dart
echo('hello', newline: false);
```

## Colour coding

DCli allows you colour code your text output.

```dart
print(orange('hello world'));
```

You can also control the background colour:

```dart
print(orange('hello world', background: AnsiColor.white));
```

The following colours are supported for both the foreground (text) and background colours.

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

By default the bold attribute is attached to each of the above builtin colours. You can suppress the bold attribute:

```
 print(red('a dark message', bold: false));
```

## Format().row

This method is considered experimental. Use at your own peril.

The row method allows you to output a row of fixed with columns with controlled alignment.

```
print(Format().row(['OS Version', '${Platform.operatingSystemVersion}'],
        widths: [17, -1]));
```

Outputs a row with two columns. The first is 17 characters wide, the second expands as needed.

```
print(Format().row([
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

## clearScreen

Clears the console.

```
clearScreen();
```

## clearLine

Clears the current line.

```
clearLine();
```

### writeLine

Writes \[text] to the console followed by a newline.&#x20;

You can control the alignment of \[text] by passing the optional \[alignment] argument which defaults to left alignment. The alignment is based on the current terminals width with spaces inserted to the left of the string to facilitate the alignment. Make certain the current line is clear and the cursor is at column 0  before calling this method otherwise the alignment will not work as expected.

## Cursors

Ansi terminals support the concept of a cursor.

Characters printed to the terminal a displayed in a grid of rows and columns.

Historically terminals were generally 24 rows x 80 columns but modern terminals can be any size.

The number of rows and columns is determined by the size of the terminal window.

A cursor describes a location on the terminal within the grid.

You can move the cursor to any location and then print text at that location.

Cursors allow you to build advanced user interfaces in a terminal window including form based input.



### startOfLine

Moves the cursor to the start of the current line.

```
startOfLine;
```

### previousLine

Moves the cursor to the start of the previous line.

### showCursor

Shows or hides the cursor.

```
showCursor(show: true);
```

### column

Moves the cursor to the given column on the current line.

### columns

Returns the number of columns currently displayed by the terminal.

This value can change at any time if the user resizes the terminal window.

### cursorUp

Moves the cursor up one row

### cursorDown

Moves the cursor down one row

### cursorLeft

Moves the cursor to the left one column

### cursorRight

Moves the cursor to the right one column

### home

Sets the cursor to the top left hand corner (column = 0, row = 0)

### row

Moves the cursor to the given row.

### rows

Returns the number of rows currently displayed by the terminal.

This value can change at any time if the user resizes the terminal window.

###

