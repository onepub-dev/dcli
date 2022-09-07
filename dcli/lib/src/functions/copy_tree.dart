/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' show CopyTreeException;

import '../../dcli.dart';

///
/// Copies the contents of the [from] directory to the
/// [to] path with an optional filter.
///
/// The [to] path must exist.
///
/// If any copied file already exists in the [to] path then
/// an exeption is throw and a parital copyTree may occur.
///
/// You can force the copyTree to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
/// The [recursive] argument controls whether subdirectories are
/// copied. If [recursive] is true (the default) it will copy
/// subdirectories.
///
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true);
/// ```
/// By default hidden files are ignored. To allow hidden files to
/// be processed set [includeHidden] to true.
///
/// You can select which files are to be copied by passing a [filter].
/// To allow a file/directory be copyied the filter returns true.
///
/// If a [filter] isn't passed then all files are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true, includeHidden:true
///    // allow only .dart files to be copied
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we copy a file.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true
///   , filter: (file) {
///   var include = extension(file) == 'dart';
///   if (include) {
///     print('copying: $file');
///   }
///   return include;
/// });
/// ```
///
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyTreeException] is thrown.
void copyTree(
  String from,
  String to, {
  bool overwrite = false,
  bool includeHidden = false,
  bool recursive = true,
  bool Function(String file) filter = _allowAll,
}) =>
    waitForEx(
      // ignore: discarded_futures
      core.copyTree(
        from,
        to,
        overwrite: overwrite,
        includeHidden: includeHidden,
        recursive: recursive,
        filter: filter,
      ),
    );

bool _allowAll(String file) => true;
