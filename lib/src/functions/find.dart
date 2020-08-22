import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import '../../dcli.dart';

import '../util/progress.dart';
import '../util/wait_for_ex.dart';

import 'function.dart';

///
/// Returns the list of files in the current and child
/// directories that match the passed glob pattern.
///
/// Each file is returned as absolute path.
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
/// String<List> results = find('[a-z]*.jpg', caseSensitive:true).toList();
///
/// find('*.jpg'
///   , types:[FileSystemEntityType.directory, FileSystemEntityType.file])
///     .forEach((file) => print(file));
/// ```
///
/// Valid patterns are:
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
/// [[!a-z]] - matches one character that is not from the range given in the bracket
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
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
///
/// [root] allows you to specify an alternate directory to seach within
/// rather than the current work directory.
///
/// [types] the list of types to search file. Defaults to file.
///   See [FileSystemEntityType].
/// [progress] a Progress to output the results to. Passing a progress will
/// allow you to process the results as the are produced rather than having
/// to wait for the call to find to complete.
/// The passed progress is also returned.
///

Progress find(
  String pattern, {
  bool caseSensitive = false,
  bool recursive = true,
  bool includeHidden = false,
  String root = '.',
  Progress progress,
  List<FileSystemEntityType> types = const [FileSystemEntityType.file],
}) =>
    Find()._find(pattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        includeHidden: includeHidden,
        root: root,
        progress: progress,
        types: types);

/// Implementation for the [_find] function.
class Find extends DCliFunction {
  Progress _find(
    String pattern, {
    bool caseSensitive = false,
    bool recursive = true,
    String root = '.',
    Progress progress,
    List<FileSystemEntityType> types = const [FileSystemEntityType.file],
    bool includeHidden,
  }) {
    var matcher = _PatternMatcher(pattern, caseSensitive: caseSensitive);
    if (root == '.') {
      root = pwd;
    }

    try {
      progress ??= Progress.devNull();

      Settings().verbose(
          'find: pwd: $pwd ${absolute(root)} pattern: $pattern caseSensitive: $caseSensitive recursive: $recursive types: $types ');

      var completer = Completer<void>();
      var lister = Directory(root).list(recursive: recursive);

      lister.listen((entity) {
        var type = FileSystemEntity.typeSync(entity.path);
        if (types.contains(type) &&
            matcher.match(basename(entity.path)) &&
            _allowed(
              root,
              entity,
              includeHidden: includeHidden,
            )) {
          progress.addToStdout(normalize(entity.path));
        }
      },
          // should also register onError
          onDone: () => completer.complete(null));

      waitForEx<void>(completer.future);
    } finally {
      progress.close();
    }

    return progress;
  }

  bool _allowed(String root, FileSystemEntity entity,
      {@required bool includeHidden}) {
    return includeHidden || !_isHidden(root, entity);
  }

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  bool _isHidden(String root, FileSystemEntity entity) {
    var relativePath = relative(entity.path, from: root);

    var parts = relativePath.split(separator);

    var isHidden = false;
    for (var part in parts) {
      if (part.startsWith('.')) {
        isHidden = true;
        break;
      }
    }
    return isHidden;
  }
}

class _PatternMatcher {
  String pattern;
  RegExp regEx;
  bool caseSensitive;

  _PatternMatcher(this.pattern, {@required this.caseSensitive}) {
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
