/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

/// Writes [content] to the file at [path].
/// The file is trunctated and then written to.
///
void writeToFile(String path, String content) {
  File file;

  file = File(path);

  file.openSync(mode: FileMode.write)
    ..writeStringSync(content)
    ..closeSync();
}
