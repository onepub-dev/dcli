import '../../dshell.dart';

/// Utility methods to aid the dshell_completion app.
///

List<String> completionExpandScripts(String word) {
  var dartScripts = find('$word*.dart', recursive: false).toList();

  var results = <String>[];
  if (word.isEmpty) {
    results = dartScripts;
  } else {
    for (var script in dartScripts) {
      if (basename(script).startsWith(word)) {
        results.add(basename(script));
      }
    }
  }

  return results;
}
