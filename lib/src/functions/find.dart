import 'dart:async';
import 'dart:io';

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
/// ```
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
  Progress? progress,
  List<FileSystemEntityType> types = const [Find.file],
}) {
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
    Progress? progress,
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden = false,
  }) {
    var finalroot = root;
    var finalpattern = pattern;

    /// If the pattern contains a relative path we need
    /// to move it into the root as the user really
    /// wants to search  in the directory root/relativepath.
    /// This only applies for non-recursive searches as
    /// when we do
    final relativeDir = dirname(finalpattern);
    if (recursive == false && relativeDir != '.') {
      finalroot = join(finalroot, relativeDir);
      if (!exists(finalroot)) {
        throw FindException('The path ${truepath(finalroot)} does not exists');
      }
      finalpattern = basename(finalpattern);
    }

    return waitForEx<Progress>(_innerFind(finalpattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        root: finalroot,
        progress: progress,
        types: types,
        includeHidden: includeHidden));
  }

  Future<Progress> _innerFind(
    String pattern, {
    bool caseSensitive = false,
    bool recursive = true,
    String root = '.',
    final Progress? progress,
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden = false,
  }) async {
    var finalroot = root;
    var finalIncludeHidden = includeHidden;

    final matcher =
        _PatternMatcher(pattern, caseSensitive: caseSensitive, root: finalroot);
    if (finalroot == '.') {
      finalroot = pwd;
    } else {
      finalroot = truepath(finalroot);
    }

    if (pattern.startsWith('.')) {
      finalIncludeHidden = true;
    }

    final Progress _progress = progress ?? Progress.devNull();
    try {
      Settings().verbose(
          'find: pwd: $pwd root: ${absolute(finalroot)} pattern: $pattern caseSensitive: $caseSensitive recursive: $recursive types: $types ');
      final nextLevel = <FileSystemEntity>[]..length = 100;
      final singleDirectory = <FileSystemEntity>[]..length = 100;
      final childDirectories = <FileSystemEntity?>[]..length = 100;
      await _processDirectory(finalroot, finalroot, recursive, types, matcher,
          finalIncludeHidden, _progress, childDirectories);

      while (childDirectories[0] != null) {
        _zeroElements(nextLevel);
        for (final directory in childDirectories) {
          if (directory == null) {
            break;
          }
          await _processDirectory(finalroot, directory.path, recursive, types,
              matcher, finalIncludeHidden, _progress, singleDirectory);
          _appendTo(nextLevel, singleDirectory);
          _zeroElements(singleDirectory);
        }
        _copyInto(childDirectories, nextLevel);
      }
    } finally {
      _progress.close();
    }
    return _progress;
  }

  Future<void> _processDirectory(
      String root,
      String currentDirectory,
      bool recursive,
      List<FileSystemEntityType> types,
      _PatternMatcher matcher,
      bool includeHidden,
      Progress progress,
      List<FileSystemEntity?> nextLevel) async {
    final lister = Directory(currentDirectory).list();
    var nextLevelIndex = 0;

    final completer = Completer<void>();

    lister.listen(
      (entity) async {
        final type = FileSystemEntity.typeSync(entity.path);
        if (types.contains(type) &&
            matcher.match(entity.path) &&
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
          if (nextLevel.length > nextLevelIndex) {
            nextLevel[nextLevelIndex++] = entity;
          } else {
            nextLevel.add(entity);
          }
        }
      },
      // should also register onError
      onDone: () => completer.complete(null),
      onError: (Object e, StackTrace st) {
        /// check for and ignore permission denied.
        if (e is FileSystemException && e.osError!.errorCode == 13) {
          Settings().verbose('Permission denied: ${e.path}');
        } else {
          throw e;
        }
      },
    );

    await completer.future;
  }

  /// Checks if a hidden file is allowed.
  /// Non-hidden files are always allowed.
  bool _allowed(String root, FileSystemEntity entity,
      {required bool includeHidden}) {
    return includeHidden || !_isHidden(root, entity);
  }

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  bool _isHidden(String root, FileSystemEntity entity) {
    final relativePath = relative(entity.path, from: root);

    final parts = relativePath.split(separator);

    var isHidden = false;
    for (final part in parts) {
      if (part.startsWith('.')) {
        isHidden = true;
        break;
      }
    }
    return isHidden;
  }

  /// set all elements in the array to null so we can re-use the list
  /// to reduce GC.
  void _zeroElements(List<FileSystemEntity?> nextLevel) {
    for (var i = 0; i < nextLevel.length && nextLevel[i] != null; i++) {
      nextLevel[i] = null;
    }
  }

  void _copyInto(List<FileSystemEntity?> childDirectories,
      List<FileSystemEntity?> nextLevel) {
    _zeroElements(childDirectories);
    for (var i = 0; i < nextLevel.length; i++) {
      if (childDirectories.length > i) {
        childDirectories[i] = nextLevel[i];
      } else {
        childDirectories.add(nextLevel[i]);
      }
    }
  }

  void _appendTo(List<FileSystemEntity?> nextLevel,
      List<FileSystemEntity?> singleDirectory) {
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

  int _firstAvailable(List<FileSystemEntity?> nextLevel) {
    var firstAvailable = 0;
    while (firstAvailable < nextLevel.length &&
        nextLevel[firstAvailable] != null) {
      firstAvailable++;
    }
    return firstAvailable;
  }

  /// pass as a value to the find types argument
  /// to select files to be found
  static const file = FileSystemEntityType.file;

  /// pass as a value to the final types argument
  /// to select directories to be found
  static const directory = FileSystemEntityType.directory;

  /// pass as a value to the final types argument
  /// to select links to be found
  static const link = FileSystemEntityType.link;
}

class _PatternMatcher {
  String pattern;
  String root;
  late RegExp regEx;
  bool caseSensitive;

  /// the no. of directories in the pattern
  int directoryParts = 0;

  _PatternMatcher(this.pattern,
      {required this.root, required this.caseSensitive}) {
    regEx = buildRegEx();

    final patternParts = split(dirname(pattern));
    directoryParts = patternParts.length;
    if (patternParts.length == 1 && patternParts[0] == '.') directoryParts = 0;
  }

  bool match(String path) {
    final matchPart = _extractMatchPart(path);
    //  print('path: $path, matchPart: $matchPart pattern: $pattern');
    return regEx.stringMatch(matchPart) == matchPart;
  }

  RegExp buildRegEx() {
    var regEx = '';

    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];

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

  /// A pattern may contain a relative path in which case
  /// we need to match [path] with the same no. of directories
  /// as is contained in the pattern.
  ///
  /// This method extracts the components of a absolute [path]
  /// that must be used when doing the pattern match.
  String _extractMatchPart(String path) {
    if (directoryParts == 0) return basename(path);

    final pathParts = split(dirname(relative(path, from: root)));

    var partsCount = pathParts.length;
    if (pathParts.length == 1 && pathParts[0] == '.') partsCount = 0;

    /// If the path doesn't have enough parts then just
    /// return the path relative to the root.
    if (partsCount < directoryParts) {
      return relative(path, from: root);
    }

    /// return just the required parts.
    return joinAll(
        [...pathParts.sublist(partsCount - directoryParts), basename(path)]);
  }
}

/// Thrown when the [find] function encouters an error.
class FindException extends FunctionException {
  /// Thrown when the [move] function encouters an error.
  FindException(String reason) : super(reason);
}
