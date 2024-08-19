/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:path/path.dart';

import '../../dcli_core.dart';

// TODO(bsutton): investigate if we need to restore the
// [LimitedStreamController]
// typedef FindController<T> = LimitedStreamController<T>;
typedef ProgressCallback = bool Function(FindItem item);

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
///   See [Find.file], [Find.directory], [Find.link].
///
/// Passing a [progress] will allow you to process the results as the are
/// produced rather than having to wait for the call to find to complete.
/// The passed progress is also returned.
/// If the [progress] doesn't output [stdout] then you will get no results
/// back.
///
// TODO(bsutton): consider having find return a Stream and eliminate passing
/// a controller in.
void find(
  String pattern, {
  required ProgressCallback progress,
  bool caseSensitive = false,
  bool recursive = true,
  bool includeHidden = false,
  String workingDirectory = '.',
  List<FileSystemEntityType> types = const [Find.file],
}) =>
    Find()._find(
      pattern,
      caseSensitive: caseSensitive,
      recursive: recursive,
      includeHidden: includeHidden,
      workingDirectory: workingDirectory,
      progress: progress,
      types: types,
    );

/// Implementation for the [_find] function.
class Find extends DCliFunction {
  final bool _closed = false;

  /// Find matching files an call [progress] for each one.
  void _find(
    String pattern, {
    required ProgressCallback progress,
    bool caseSensitive = false,
    bool recursive = true,
    String workingDirectory = '.',
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden = false,
  }) {
    final config = FindConfig.build(
        pattern: pattern,
        workingDirectory: workingDirectory,
        includeHidden: includeHidden,
        caseSensitive: caseSensitive);

    _innerFind(
      config: config,
      recursive: recursive,
      progress: progress,
      types: types,
    );
  }

  void _innerFind({
    required FindConfig config,
    required ProgressCallback progress,
    bool recursive = true,
    List<FileSystemEntityType> types = const [Find.file],
  }) {
    verbose(
      () => 'find: pwd: $pwd '
          'workingDirectory: ${truepath(config.workingDirectory)} '
          'pattern: ${config.pattern} caseSensitive: ${config.caseSensitive} '
          'recursive: $recursive types: $types ',
    );
    final nextLevel = List<FileSystemEntity?>.filled(100, null, growable: true);
    final singleDirectory =
        List<FileSystemEntity?>.filled(100, null, growable: true);
    final childDirectories =
        List<FileSystemEntity?>.filled(100, null, growable: true);
    if (!_processDirectory(
      config.workingDirectory,
      config.workingDirectory,
      recursive,
      types,
      config.matcher,
      config.includeHidden,
      progress,
      childDirectories,
    )) {
      return;
    }
    while (childDirectories[0] != null) {
      _zeroElements(nextLevel);
      for (final directory in childDirectories) {
        if (directory == null) {
          break;
        }
        // print('calling _processDirectory ${count++}');
        if (!_processDirectory(
          config.workingDirectory,
          directory.path,
          recursive,
          types,
          config.matcher,
          config.includeHidden,
          progress,
          singleDirectory,
        )) {
          break;
        }
        _appendTo(nextLevel, singleDirectory);
        _zeroElements(singleDirectory);
      }
      _copyInto(childDirectories, nextLevel);
    }
  }

  bool _processDirectory(
    String workingDirectory,
    String currentDirectory,
    bool recursive,
    List<FileSystemEntityType> types,
    PatternMatcher matcher,
    bool includeHidden,
    ProgressCallback progress,
    List<FileSystemEntity?> nextLevel,
  ) {
    // print('process Directory ${dircount++}');
    final list = Directory(currentDirectory).listSync(followLinks: false);

    var nextLevelIndex = 0;

    for (final entity in list) {
      try {
        late final FileSystemEntityType type;
        type = FileSystemEntity.typeSync(entity.path, followLinks: false);

        if (types.contains(type) &&
            matcher.match(entity.path) &&
            _allowed(
              workingDirectory,
              entity,
              includeHidden: includeHidden,
            )) {
          if (_closed) {
            return false;
          }

          /// If the controller has been paused or hasn't yet been
          /// listened to then we don't want to add files to
          /// it otherwise we may run out of memory.
          if (!progress(FindItem(entity.path, type))) {
            return false;
          }
        }

        /// If we are recursing then we need to add any directories
        /// to the list of childDirectories that need to be recursed.
        if (recursive && type == Find.directory) {
          if (nextLevel.length > nextLevelIndex) {
            nextLevel[nextLevelIndex] = entity;
          } else {
            nextLevel.add(entity);
          }
          nextLevelIndex++;
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        if (_isGeneralIOError(e)) {
          /// can mean a corrupt disk, problems with virtualisation
          /// I've seen this when gdrive.
        } else if (e is FileSystemException &&
            e.osError?.errorCode == _accessDenied) {
          /// check for and ignore permission denied.
          verbose(() => 'Permission denied: ${e.path}');
        } else if (e is FileSystemException && e.osError?.errorCode == 40) {
          /// ignore recursive symbolic link problems.
          verbose(() => 'Too many levels of symbolic links: ${e.path}');
        } else if (e is FileSystemException && e.osError?.errorCode == 22) {
          /// Invalid argument - not really certain what this means but we get
          /// it when processing a .steam folder that includes a windows
          /// emulator.
          verbose(() => 'Invalid argument: ${e.path}');
        } else if (e is FileSystemException &&
            e.osError?.errorCode == _directoryNotFound) {
          /// The directory may have been deleted between us finding it and
          /// processing it.
          verbose(
            () => 'File or Directory deleted whilst we were processing it:'
                ' ${e.path}',
          );
        } else {
          // ignore: only_throw_errors
          rethrow;
        }
      }
    }
    return true;
  }

  int get _accessDenied => Settings().isWindows ? 5 : 13;
  int get _directoryNotFound => Settings().isWindows ? 3 : 2;

  /// Checks if a hidden file is allowed.
  /// Non-hidden files are always allowed.
  bool _allowed(
    String workingDirectory,
    FileSystemEntity entity, {
    required bool includeHidden,
  }) =>
      includeHidden || !_isHidden(workingDirectory, entity);

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  bool _isHidden(String workingDirectory, FileSystemEntity entity) {
    final relativePath = relative(entity.path, from: workingDirectory);

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

  void _copyInto(
    List<FileSystemEntity?> childDirectories,
    List<FileSystemEntity?> nextLevel,
  ) {
    _zeroElements(childDirectories);
    for (var i = 0; i < nextLevel.length; i++) {
      if (childDirectories.length > i) {
        childDirectories[i] = nextLevel[i];
      } else {
        childDirectories.add(nextLevel[i]);
      }
    }
  }

  void _appendTo(
    List<FileSystemEntity?> nextLevel,
    List<FileSystemEntity?> singleDirectory,
  ) {
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

  bool _isGeneralIOError(Object e) {
    var error = false;
    error = e is FileSystemException &&
        !Platform.isWindows &&
        e.osError?.errorCode == 5;

    if (error) {
      verbose(() => 'General IO Error(5) accessing: ${e.path}');
    }

    return error;
  }
}

class PatternMatcher {
  PatternMatcher(
    this.pattern, {
    required this.workingDirectory,
    required this.caseSensitive,
  }) {
    regEx = buildRegEx();

    final patternParts = split(dirname(pattern));
    var count = patternParts.length;
    if (patternParts.length == 1 && patternParts[0] == '.') {
      count = 0;
    }
    directoryParts = count;
  }

  String pattern;
  String workingDirectory;
  late RegExp regEx;
  bool caseSensitive;

  /// the no. of directories in the pattern
  late final int directoryParts;

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
        case ']':
          regEx += ']';
        case '*':
          regEx += '.*';
        case '?':
          regEx += '.';
        case '-':
          regEx += '-';
        case '!':
          regEx += '^';
        case '.':
          regEx += r'\.';
        case r'\':
          regEx += r'\\';
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
    if (directoryParts == 0) {
      return basename(path);
    }

    final pathParts = split(dirname(relative(path, from: workingDirectory)));

    var partsCount = pathParts.length;
    if (pathParts.length == 1 && pathParts[0] == '.') {
      partsCount = 0;
    }

    /// If the path doesn't have enough parts then just
    /// return the path relative to the workingDirectory.
    if (partsCount < directoryParts) {
      return relative(path, from: workingDirectory);
    }

    /// return just the required parts.
    return joinAll(
      [...pathParts.sublist(partsCount - directoryParts), basename(path)],
    );
  }
}

//typedef FindProgress = Future<void> Function(String path);
//typedef FindProgress = Sink<FindItem>();

/// Holds details of a file system entity returned by the
/// [find] function.
class FindItem {
  /// [pathTo] is the path to the file system entity
  /// [type] is the type of file system entity.
  FindItem(this.pathTo, this.type);

  ///  the path to the file system entity
  String pathTo;

  /// type of file system entity
  FileSystemEntityType type;

  @override
  String toString() => pathTo;
}

/// Thrown when the [find] function encouters an error.
class FindException extends DCliFunctionException {
  /// Thrown when the [move] function encouters an error.
  FindException(super.message);
}

class FindConfig {
  factory FindConfig.build(
      {required String pattern,
      required String workingDirectory,
      required bool includeHidden,
      required bool caseSensitive}) {
    /// strip any path components out of the pattern
    /// and add them to the working directory.
    /// If there is no dirname component we get '.'
    final directoryPart = dirname(pattern);
    if (directoryPart != '.') {
      workingDirectory = join(workingDirectory, directoryPart);
    }
    pattern = basename(pattern);

    if (!exists(workingDirectory)) {
      throw FindException(
        'The path ${truepath(workingDirectory)} does not exists',
      );
    }

    final matcher = PatternMatcher(
      pattern,
      caseSensitive: caseSensitive,
      workingDirectory: workingDirectory,
    );
    if (workingDirectory == '.') {
      workingDirectory = pwd;
    } else {
      workingDirectory = truepath(workingDirectory);
    }

    if (basename(pattern).startsWith('.')) {
      includeHidden = true;
    }

    return FindConfig._(
        workingDirectory: workingDirectory,
        pattern: pattern,
        includeHidden: includeHidden,
        caseSensitive: caseSensitive,
        matcher: matcher);
  }
  FindConfig._(
      {required this.workingDirectory,
      required this.pattern,
      required this.includeHidden,
      required this.caseSensitive,
      required this.matcher});
  String workingDirectory;
  String pattern;
  bool includeHidden;
  bool caseSensitive;
  PatternMatcher matcher;
}
