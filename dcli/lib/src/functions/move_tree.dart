/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart' show MoveTreeException;

/// Recursively moves the contents of the [from] directory to the
/// to the [to] path with an optional filter.
///
/// When filtering any files that don't match the filter will be
/// left in the [from] directory tree.
///
/// Any [from] directories that are emptied as a result of the move will
/// be removed. This includes the [from] directory itself.
///
/// [from] must be a directory
///
/// [to] must be a directory and its parent directory must exist.
///
/// If any moved files already exists in the [to] path then
/// an exeption is throw and a parital move may occured.
///
/// You can force moveTree to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true);
/// ```
///
/// By default hidden files are ignored. To allow hidden files to
/// be passed set [includeHidden] to true.
///
/// You can select which files/directories are to be moved by passing a [filter].
/// If a [filter] isn't passed then all files/directories are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we move a file or directory.
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true
///   , filter: (entity) {
///   var include = extension(entity) == 'dart';
///   if (include) {
///     print('moving: $file');
///   }
///   return include;
/// });
/// ```
///
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [MoveTreeException] is thrown.
///
/// EXPERIMENTAL
void moveTree(
  String from,
  String to, {
  bool overwrite = false,
  bool includeHidden = false,
  bool Function(String file) filter = _allowAll,
}) =>
    waitForEx(
      core.moveTree(
        from,
        to,
        overwrite: overwrite,
        includeHidden: includeHidden,
        filter: filter,
      ),
    );

bool _allowAll(String file) => true;
