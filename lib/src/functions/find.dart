import 'dart:io';

import 'function.dart';
import '../util/progress.dart';

import '../../dshell.dart';

import '../util/log.dart';

///
/// Returns the list of files in the current
/// directory that match the passed glob pattern.
///
/// ```dart
/// find('*.jpg', recursive=true).forEach((file) => print(file));
///
/// String<List> results = find('[a-z]*.jpg', caseSensitive=true).toList();
///
/// find('*.jpg'
///   , types=[FileSystemEntityType.directory, FileSystemEntityType.file])
///     .forEach((file) => print(file));
/// ```
///
/// Valid patterns are:
///
/// Note> the surround square brackets are not part of the pattern.
///
/// [*] - matches any number of any characters including none
///
/// [?] -  matches any single character
///
/// [[abc]] - matches any one character given in the bracket
///
/// [[a-z]] - matches one character from the range given in the bracket
///
/// [[!abc]] - matches one character that is not given in the bracket
///
/// [[!a-z]] - matches one character that is not from the range given in the bracket
///
/// If [caseSensitive] is true then a case sensitive match is performed.
/// [caseSensitive] defaults to false.
///
/// If [recursive] is true then a recursive search of all subdirectories
///    (all the way down) is performed.
/// [recursive] is true by default.
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
///

Progress find(String pattern,
        {bool caseSensitive = false,
        bool recursive = true,
        String root = '.',
        Progress progress,
        List<FileSystemEntityType> types = const [
          FileSystemEntityType.file
        ]}) =>
    Find().find(pattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        root: root,
        progress: progress,
        types: types);

class Find extends DShellFunction {
  Progress find(String pattern,
      {bool caseSensitive = false,
      bool recursive = true,
      String root = '.',
      Progress progress,
      List<FileSystemEntityType> types = const [FileSystemEntityType.file]}) {
    var matcher = PatternMatcher(pattern, caseSensitive);

    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();

      if (Settings().debug_on) {
        Log.d(
            'find: pwd: ${pwd} ${absolute(root)} pattern: ${pattern} caseSensitive: ${caseSensitive} recursive: ${recursive} types: ${types} ');
      }

      // get all files for consideration
      // this could be problematic for a large tree.
      // would be better if we process the files as we went.
      var all = Directory(root).listSync(recursive: recursive);

      // TODO: consider doing a directory at a time so we don't blow all memory.
      for (var entity in all) {
        var type = FileSystemEntity.typeSync(entity.path);
        if (types.contains(type) && matcher.match(entity.path)) {
          forEach.addToStdout(entity.path);
        }
      }
    } finally {
      forEach.close();
    }

    return forEach;
  }
}

class PatternMatcher {
  String pattern;
  RegExp regEx;
  bool caseSensitive;

  PatternMatcher(this.pattern, this.caseSensitive) {
    regEx = buildRegEx();
  }

  bool match(String value) {
    return regEx.stringMatch(value) == value;
  }

  RegExp buildRegEx() {
    var regEx = '';

    for (var i = 0; i < pattern.length; i++) {
      var char = pattern[i];

      switch (char) {
        case '[':
          regEx += '[';
          break;
        case ']':
          regEx += ']';
          break;
        case '*':
          regEx += '.*';
          break;
        case '?':
          regEx += '.';
          break;
        case '-':
          regEx += '-';
          break;
        case '!':
          regEx += '^';
          break;
        case '.':
          regEx += '\\.';
          break;
        default:
          regEx += char;
          break;
      }
    }
    return RegExp(regEx, caseSensitive: caseSensitive);
  }
}
