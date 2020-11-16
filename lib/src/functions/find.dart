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
/// List<String> results = find('[a-z]*.jpg', caseSensitive:true).toList();
///
/// find('*.jpg'
///   , types:[Find.directory, Find.file])
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
/// If the wildcard begins with a '.' then includeHidden will be enabled
/// automatically.
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
///
/// [root] allows you to specify an alternate directory to seach within
/// rather than the current work directory.
///
/// [types] the list of types to search file. Defaults to [Find.file].
///   See [Find.file], [Find.directory], [Find.link].
///
/// Passing a [progress] will allow you to process the results as the are
/// produced rather than having to wait for the call to find to complete.
/// The passed progress is also returned.
///

Progress find(
  String pattern, {
  bool caseSensitive = false,
  bool recursive = true,
  bool includeHidden = false,
  String root = '.',
  Progress progress,
  List<FileSystemEntityType> types = const [Find.file],
}) {
  ArgumentError.checkNotNull(caseSensitive, 'caseSensitive');
  ArgumentError.checkNotNull(recursive, 'recursive');
  ArgumentError.checkNotNull(includeHidden, 'includeHidden');
  ArgumentError.checkNotNull(root, 'root');
  ArgumentError.checkNotNull(types, 'types');
  return Find()._find(pattern,
      caseSensitive: caseSensitive,
      recursive: recursive,
      includeHidden: includeHidden,
      root: root,
      progress: progress,
      types: types);
}

/// Implementation for the [_find] function.
class Find extends DCliFunction {
  Progress _find(
    String pattern, {
    bool caseSensitive = false,
    bool recursive = true,
    String root = '.',
    Progress progress,
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden,
  }) {
    return waitForEx<Progress>(_innerFind(pattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        root: root,
        progress: progress,
        types: types,
        includeHidden: includeHidden));
  }

  Future<Progress> _innerFind(
    String pattern, {
    bool caseSensitive = false,
    bool recursive = true,
    String root = '.',
    Progress progress,
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden,
  }) async {
    var matcher = _PatternMatcher(pattern, caseSensitive: caseSensitive);
    if (root == '.') {
      root = pwd;
    } else {
      root = truepath(root);
    }

    if (pattern.startsWith('.')) {
      includeHidden = true;
    }

    try {
      progress ??= Progress.devNull();

      Settings().verbose(
          'find: pwd: $pwd ${absolute(root)} pattern: $pattern caseSensitive: $caseSensitive recursive: $recursive types: $types ');
      var nextLevel = <FileSystemEntity>[]..length = 100;
      var singleDirectory = <FileSystemEntity>[]..length = 100;
      var childDirectories = <FileSystemEntity>[]..length = 100;
      await _processDirectory(root, root, recursive, types, matcher, includeHidden, progress, childDirectories);

      while (childDirectories[0] != null) {
        _zeroElements(nextLevel);
        for (var directory in childDirectories) {
          if (directory == null) {
            break;
          }
          await _processDirectory(
              root, directory.path, recursive, types, matcher, includeHidden, progress, singleDirectory);
          _appendTo(nextLevel, singleDirectory);
          _zeroElements(singleDirectory);
        }
        _copyInto(childDirectories, nextLevel);
      }
    } finally {
      progress.close();
    }
    return progress;
  }

  Future<void> _processDirectory(String root, String currentDirectory, bool recursive, List<FileSystemEntityType> types,
      _PatternMatcher matcher, bool includeHidden, Progress progress, List<FileSystemEntity> nextLevel) async {
    var lister = Directory(currentDirectory).list(recursive: false);
    var nextLevelIndex = 0;

    var completer = Completer<void>();

    lister.listen(
      (entity) async {
        var type = FileSystemEntity.typeSync(entity.path);
        if (types.contains(type) &&
            matcher.match(basename(entity.path)) &&
            _allowed(
              root,
              entity,
              includeHidden: includeHidden,
            )) {
          progress.addToStdout(entity.path);
        }

        /// If we are recursing then we need to add any directories
        /// to the list of childDirectories that need to be recursed.
        if (recursive && type == Find.directory) {
          // processing the /proc directory causes dart to crash
          // https://github.com/dart-lang/sdk/issues/43176
          if (entity.path != '/proc' && entity.path != '/dev' && entity.path != '/snap' && entity.path != '/sys') {
            if (nextLevel.length > nextLevelIndex) {
              nextLevel[nextLevelIndex++] = entity;
            } else {
              nextLevel.add(entity);
            }
          }
        }
      },
      // should also register onError
      onDone: () => completer.complete(null),
      onError: (Object e, StackTrace st) {
        /// check for and ignore permission denied.
        if (e is FileSystemException && e.osError.errorCode == 13) {
          Settings().verbose('Permission denied: ${e.path}');
        } else {
          throw e;
        }
      },
    );

    await completer.future;
  }

  bool _allowed(String root, FileSystemEntity entity, {@required bool includeHidden}) {
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

  /// set all elements in the array to null so we can re-use the list
  /// to reduce GC.
  void _zeroElements(List<FileSystemEntity> nextLevel) {
    for (var i = 0; i < nextLevel.length && nextLevel[i] != null; i++) {
      nextLevel[i] = null;
    }
  }

  void _copyInto(List<FileSystemEntity> childDirectories, List<FileSystemEntity> nextLevel) {
    _zeroElements(childDirectories);
    for (var i = 0; i < nextLevel.length; i++) {
      if (childDirectories.length > i) {
        childDirectories[i] = nextLevel[i];
      } else {
        childDirectories.add(nextLevel[i]);
      }
    }
  }

  void _appendTo(List<FileSystemEntity> nextLevel, List<FileSystemEntity> singleDirectory) {
    var index = _firstAvailable(nextLevel);

    for (var i = 0; i < singleDirectory.length; i++) {
      if (singleDirectory[i] == null) {
        break;
      }
      if (index >= nextLevel.length) {
        nextLevel.add(singleDirectory[i]);
        index++;
      } else {
        nextLevel[index++] = singleDirectory[i];
      }
    }
  }

  int _firstAvailable(List<FileSystemEntity> nextLevel) {
    var firstAvailable = 0;
    while (firstAvailable < nextLevel.length && nextLevel[firstAvailable] != null) {
      firstAvailable++;
    }
    return firstAvailable;
  }

  /// pass as an argument to the [types] argument
  /// to select files to be found
  static const file = FileSystemEntityType.file;

  /// pass as an argument to the [types] argument
  /// to select directories to be found
  static const directory = FileSystemEntityType.directory;

  /// pass as an argument to the [types] argument
  /// to select links to be found
  static const link = FileSystemEntityType.link;
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
