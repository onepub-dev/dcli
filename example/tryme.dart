#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
  echo('Hello World');
  echo('Where are we: ${pwd}?');

  createDir('test');
  push('test');
  touch('icon.png');
  touch('logo.png');
  touch('dog.png');

  // print all the file names in the current directory.
  fileList.forEach((file) => print('Found: ${file}'));

  touch('subdir/monkey.png');

  // do a recursive find
  find('*.png').forEach((file) => print('$file'));

  // now cleanup
  delete('icon.png');
  delete('logo.png');
  delete('dog.png');

  pop();

  'grep touch tryme.dart'.forEach((line) => print('Found: $line'));
}
