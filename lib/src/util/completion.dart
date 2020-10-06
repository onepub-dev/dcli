import 'dart:io';

import '../../dcli.dart';

/// Utility methods to aid the dcli_completion app.
///

List<String> completionExpandScripts(String word,
    {String workingDirectory = '.'}) {
  var root = workingDirectory;

  var searchTerm = word;
  if (word.isNotEmpty) {
    var parts = split(word);

    searchTerm = parts.last;

    if (parts.length > 1) {
      root = join(root,
          parts.sublist(0, parts.length - 1).join(Platform.pathSeparator));
    }
  }

  /// if the searchTerm is actually a directory name
  /// then we need to use the directory as the root so we
  /// search in it.
  if (exists(join(root, searchTerm))) {
    root = join(root, searchTerm);
    searchTerm = '';
  }
  var entries = find('$searchTerm*',
          types: [Find.directory, Find.file], root: root, recursive: false)
      .toList();

  var results = <String>[];
  for (var script in entries) {
    if (word.isEmpty ||
        relative(script, from: workingDirectory).startsWith(word)) {
      var matchPath = join(root, script);
      if (isDirectory(matchPath)) {
        // its a directory add trailing slash and returning.
        results.add('${relative('$script', from: workingDirectory)}/');
      } else {
        results.add(relative(script, from: workingDirectory));
      }
    }
  }

  return results;
}
