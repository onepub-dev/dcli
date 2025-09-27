/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import 'internal_progress.dart';

export 'package:dcli_core/dcli_core.dart' show Find;

// export 'package:dcli_core/.dart' show Find.directory;

///
/// Returns the list of files in the current and child
/// directories that match the passed glob pattern.
///
/// Each file is returned as an absolute path.
///
/// You can obtain a relative path by calling:
/// ```dart
/// var relativePath = relative(filePath, from: searchRoot);
/// ```
///
/// Note: this is a limited implementation of glob.
/// See the below notes for details.
///
/// ```dart
/// find('*.jpg', recursive:true).forEach((file) => print(file));
///
/// List<String> results = find('[a-z]*.jpg', caseSensitive:true).toList();
///
/// find('*.jpg'
///   , types:[Find.directory, Find.file])
///     .forEach((file) => print(file));
/// ```
///
/// Valid patterns are:
/// ```text
///
/// [*] - matches any number of any characters including none.
///
/// [?] -  matches any single character
///
/// [[abc]] - matches any one character given in the bracket
///
/// [[a-z]] - matches one character from the range given in the bracket
///
/// [[!abc]] - matches one character that is not given in the bracket
///
/// [[!a-z]] - matches one character that is not from the range given
///  in the bracket
/// ```
///
/// If [caseSensitive] is true then a case sensitive match is performed.
/// [caseSensitive] defaults to false.
///
/// If [recursive] is true then a recursive search of all subdirectories
///    (all the way down) is performed.
/// [recursive] is true by default.
///
/// [includeHidden] controls whether hidden files (.xx) are returned and
/// whether hidden directorys (.xx) are recursed into when the [recursive]
/// option is true. By default hidden files and directories are ignored.
/// If the wildcard begins with a '.' then includeHidden will be enabled
/// automatically.
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
///
/// [workingDirectory] allows you to specify an alternate d
/// irectory to seach within
/// rather than the current work directory.
///
/// [types] the list of types to search file. Defaults to [Find.file].
///
/// See:
///  * [Find.file]
///  * [Find.directory]
///  * [Find.link].
///
/// Passing a [progress] will allow you to process the results as the are
/// produced rather than having to wait for the call to find to complete.
/// The passed progress is also returned.
/// If the [progress] doesn't output [stdout] then you will get no results
/// back.
///

FindProgress find(
  String pattern, {
  bool caseSensitive = false,
  bool recursive = true,
  bool includeHidden = false,
  String workingDirectory = '.',
  Progress? progress,
  List<FileSystemEntityType> types = const [Find.file],
}) {
  progress ??= Progress.devNull();
  return FindProgress(
    pattern,
    caseSensitive: caseSensitive,
    recursion: recursive,
    includeHidden: includeHidden,
    workingDirectory: workingDirectory,
    types: types,
  );
}

///
class FindProgress extends InternalProgress {
  /// The glob pattern we are searching for matches on
  String pattern;

  /// If true then we do a case sensitive match on filenames.
  bool caseSensitive;

  /// recurse into subdirectories
  bool recursion;

  /// include hidden files and directories in the search
  bool includeHidden;

  /// The directory to start searching from and below (if [recursion] is true)
  String workingDirectory;

  /// The list of file system entity types to search file.
  List<FileSystemEntityType> types;

  ///
  FindProgress(
    this.pattern, {
    required this.caseSensitive,
    required this.recursion,
    required this.includeHidden,
    required this.workingDirectory,
    required this.types,
  });

  /// If you need to perform async operations you should use
  ///  [core.find].
  @override
  void forEach(LineAction action) => _forEach((line) {
        action(line);
        return true;
      });

  /// Internal method so we can cancel the stream.
  void _forEach(CancelableLineAction action) {
    core.find(
      pattern,
      caseSensitive: caseSensitive,
      recursive: recursion,
      includeHidden: includeHidden,
      workingDirectory: workingDirectory,
      progress: (item) => action(item.pathTo),
      types: types,
    );
  }

  /// Returns the first line from the command or
  /// null if no lines where returned
  String? get firstLine {
    String? first;
    _forEach((line) {
      first ??= line;
      return false;
    });
    return first;
  }
}
