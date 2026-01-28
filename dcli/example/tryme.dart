#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(TouchException)
void main() {
  echo('Hello World');
  echo('Where are we: $pwd?');

  const dir = 'test';
  createDir(dir);
  touch(join(dir, 'icon.png'));
  touch(join(dir, 'logo.png'));
  touch(join(dir, 'dog.png'));

  // print all the file names in the current directory.
  for (final file in fileList) {
    print('Found: $file');
  }

  touch(join(dir, 'subdir', 'monkey.png'));

  // do a recursive find
  find('*.png').forEach(print);

  // now cleanup
  delete(join(dir, 'icon.png'));
  delete(join(dir, 'logo.png'));
  delete(join(dir, 'dog.png'));

  'grep touch tryme.dart'.forEach((line) => print('Found: $line'));
}
