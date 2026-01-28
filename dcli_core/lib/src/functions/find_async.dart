/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../dcli_core.dart';

///
/// Returns the list of files in the current and child
/// directories that match the passed glob pattern as a Stream
/// of absolute paths.
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
/// await for (final file in find('*.jpg', recursive:true))
///    print(file);
///
/// List<String> results = findAsync('[a-z]*.jpg', caseSensitive:true).toList();
///
/// await for (final file in find('*.jpg', types:[Find.directory, Find.file])
///      print(file);
/// ```
///
/// Valid patterns are:
/// ```none
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
/// @Throwing(ArgumentError)
/// @Throwing(FileSystemException)
/// @Throwing(PathException)
/// @Throwing(RangeError)
Stream<FindItem> findAsync(
  String pattern, {
  bool caseSensitive = false,
  bool recursive = true,
  bool includeHidden = false,
  String workingDirectory = '.',
  List<FileSystemEntityType> types = const [Find.file],
}) async* {
  // We us a [LimitedStreamController] as a slow reader
  // can cause an out of memory exception if we keep pumping
  // more files into the stream.
  // ignore: close_sinks
  final controller = LimitedStreamController<FindItem>(100);
  await FindAsync()._findAsync(
    pattern,
    caseSensitive: caseSensitive,
    recursive: recursive,
    includeHidden: includeHidden,
    workingDirectory: workingDirectory,
    controller: controller,
    types: types,
  );

  yield* controller.stream;
}

/// Implementation for the [_findAsync] function.
class FindAsync extends DCliFunction {
  final _closed = false;

  /// Find matching files and return them as a stream
  /// @Throwing(ArgumentError)
  /// @Throwing(FileSystemException)
  /// @Throwing(PathException)
  /// @Throwing(RangeError)
  Future<void> _findAsync(
    String pattern, {
    required LimitedStreamController<FindItem> controller,
    bool caseSensitive = false,
    bool recursive = true,
    String workingDirectory = '.',
    List<FileSystemEntityType> types = const [Find.file],
    bool includeHidden = false,
  }) async {
    final config = FindConfig.build(
        pattern: pattern,
        workingDirectory: workingDirectory,
        includeHidden: includeHidden,
        caseSensitive: caseSensitive);

    await _innerFindAsync(
      config: config,
      recursive: recursive,
      controller: controller,
      types: types,
    );
  }

  /// @Throwing(ArgumentError)
  /// @Throwing(FileSystemException)
  /// @Throwing(PathException)
  /// @Throwing(RangeError)
  Future<void> _innerFindAsync({
    required FindConfig config,
    required LimitedStreamController<FindItem> controller,
    bool recursive = true,
    List<FileSystemEntityType> types = const [Find.file],
  }) async {
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

    if (!await _processDirectory(
      config,
      config.workingDirectory,
      recursive,
      types,
      controller,
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
        if (!await _processDirectory(
          config,
          directory.path,
          recursive,
          types,
          controller,
          singleDirectory,
        )) {
          break;
        }
        _appendTo(nextLevel, singleDirectory);
        _zeroElements(singleDirectory);
      }
      _copyInto(childDirectories, nextLevel);
    }
    unawaited(controller.close());
  }

  /// @Throwing(ArgumentError)
  /// @Throwing(FileSystemException)
  /// @Throwing(PathException)
  /// @Throwing(RangeError)
  Future<bool> _processDirectory(
    FindConfig config,
    String currentDirectory,
    bool recursive,
    List<FileSystemEntityType> types,
    LimitedStreamController<FindItem> controller,
    List<FileSystemEntity?> nextLevel,
  ) async {
    // print('process Directory ${dircount++}');

    var nextLevelIndex = 0;

    await for (final entity
        in Directory(currentDirectory).list(followLinks: false)) {
      try {
        late final FileSystemEntityType type;
        type = FileSystemEntity.typeSync(entity.path, followLinks: false);

        if (types.contains(type) &&
            config.matcher.match(entity.path) &&
            _allowed(
              config.workingDirectory,
              entity,
              includeHidden: config.includeHidden,
            )) {
          if (_closed) {
            return false;
          }

          // TODO(bsutton): do we need to wait if the controller is
          /// paused?
          await controller.asyncAdd(FindItem(entity.path, type));
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
  /// @Throwing(ArgumentError)
  /// @Throwing(PathException)
  bool _allowed(
    String workingDirectory,
    FileSystemEntity entity, {
    required bool includeHidden,
  }) =>
      includeHidden || !_isHidden(workingDirectory, entity);

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  /// @Throwing(ArgumentError)
  /// @Throwing(PathException)
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
  static const FileSystemEntityType file = FileSystemEntityType.file;

  /// pass as a value to the final types argument
  /// to select directories to be found
  static const FileSystemEntityType directory = FileSystemEntityType.directory;

  /// pass as a value to the final types argument
  /// to select links to be found
  static const FileSystemEntityType link = FileSystemEntityType.link;

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
