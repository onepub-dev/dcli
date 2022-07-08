/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

///
/// devNull is a convenience function which you can use
/// if you want to ignore the output of a LineAction.
/// Its typical useage is a forEach where you don't want
/// to see any stdout but you still want to see errors
/// printed to stderr.
///
/// ```dart
/// 'git pull'.forEach(devNull, stderr: (line) => printerr(line));
/// ```
///
/// use this to consume the output.
void devNull(String? line) {}
