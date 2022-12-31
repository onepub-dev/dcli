/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:path/path.dart';

import '../../dcli.dart';

/// Utility methods to aid the dcli_completion app.
///
/// If [extension] is passed then only files that
/// end with [extension] are returned (plus directories)
List<String> completionExpandScripts(
  String word, {
  String workingDirectory = '.',
  String? extension,
}) {
  var workingDirectory0 = workingDirectory;

  var searchTerm = word;

  // a trailing slash and we treat the word as a directory.
  if (word.endsWith(Platform.pathSeparator)) {
    workingDirectory0 = join(workingDirectory0, word);
    searchTerm = '';
  } else {
    // no trailing slash but the word may contain a directory path
    // in which case we use the last part as the search term
    // and append any remaining path to the workingDirectory.
    if (word.isNotEmpty) {
      final parts = split(word);

      searchTerm = parts.last;

      if (parts.length > 1) {
        workingDirectory0 = join(
          workingDirectory0,
          parts.sublist(0, parts.length - 1).join(Platform.pathSeparator),
        );
      }
    }
  }

  /// if the resulting path is invalid return an empty list.
  if (!exists(workingDirectory0)) {
    return <String>[];
  }

  // /// if the work ends in a slash then we treat it as a directory
  // /// then we need to use the directory as the workingDirectory so we
  // /// search in it.
  // if (exists(join(workingDirectory, searchTerm))) {
  //   workingDirectory = join(workingDirectory, searchTerm);
  //   searchTerm = '';
  // }

  final entries = find(
    '$searchTerm*',
    types: [Find.directory, Find.file],
    workingDirectory: workingDirectory0,
    recursive: false,
  ).toList();

  final results = <String>[];
  for (final script in entries) {
    if (word.isEmpty ||
        relative(script, from: workingDirectory).startsWith(word)) {
      final matchPath = join(workingDirectory0, script);
      String filePath;
      if (isDirectory(matchPath)) {
        // its a directory add trailing slash and returning.
        filePath = '${relative(script, from: workingDirectory)}/';
      } else {
        // its a file
        // If extension is passed we only return files that match the extension.
        if (extension != null && !script.endsWith(extension)) {
          continue;
        }
        filePath = relative(script, from: workingDirectory);
      }
      if (filePath.contains(' ')) {
        /// we quote filenames that include a space
        filePath = '"$filePath"';
      }
      results.add(filePath);
    }
  }

  return results;
}
