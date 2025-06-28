/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';

import '../../dcli_core.dart';

///
/// Copies the contents of the [from] directory to the
/// [to] path with an optional filter.
///
/// The [to] path must exist.
///
/// If any copied file already exists in the [to] path then
/// an exception is thrown and a partial copyTree may occur.
///
/// You can force the copyTree to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
/// The [recursive] argument controls whether subdirectories are
/// copied. If [recursive] is true (the default) it will copy
/// subdirectories.
///
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true);
/// ```
///
/// By default hidden files are ignored. To allow hidden files to
/// be processed set [includeHidden] to true.
///
/// You can select which files are to be copied by passing a [filter].
/// If a [filter] isn't passed then all files are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true, includeHidden:true,
///   filter: (file) => extension(file) == '.dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we copy a file.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true,
///   filter: (file) {
///     var include = extension(file) == '.dart';
///     if (include) {
///       print('copying: $file');
///     }
///     return include;
///   });
/// ```
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyTreeException] is thrown.
void copyTree(
  String from,
  String to, {
  bool overwrite = false,
  bool includeHidden = false,
  bool includeEmpty = true,
  bool includeLinks = true,
  bool recursive = true,
  bool Function(String file) filter = _allowAll,
}) =>
    _CopyTree().copyTree(
      from,
      to,
      overwrite: overwrite,
      includeHidden: includeHidden,
      includeEmpty: includeEmpty,
      includeLinks: includeLinks,
      filter: filter,
      recursive: recursive,
    );

bool _allowAll(String file) => true;

class _CopyTree extends DCliFunction {
  void copyTree(
    String from,
    String to, {
    bool overwrite = false,
    bool includeEmpty = true,
    bool includeLinks = true,
    bool Function(String file) filter = _allowAll,
    bool includeHidden = false,
    bool recursive = true,
  }) {
    verbose(() => '''
copyTree: from: $from, to: $to, overwrite: $overwrite, 
includeHidden: $includeHidden, includeEmpty: $includeEmpty, includeLinks: $includeLinks, recursive: $recursive''');
    if (!isDirectory(from)) {
      throw CopyTreeException(
        'The [from] path ${truepath(from)} must be a directory.',
      );
    }
    if (!exists(to)) {
      throw CopyTreeException(
        'The [to] path ${truepath(to)} must already exist.',
      );
    }

    if (!isDirectory(to)) {
      throw CopyTreeException(
        'The [to] path ${truepath(to)} must be a directory.',
      );
    }

    try {
      // Determine which types to find based on the includeLinks flag.
      final typesToFind = includeLinks
          ? [Find.file, Find.directory, Find.link]
          : [Find.file, Find.directory];

      find(
        '*',
        workingDirectory: from,
        includeHidden: includeHidden,
        types: typesToFind,
        recursive: recursive,
        progress: (item) {
          _process(
            item.pathTo,
            filter,
            from,
            to,
            includeLinks: includeLinks,
            includeEmpty: includeEmpty,
            includeHidden: includeHidden,
            overwrite: overwrite,
            recursive: recursive,
          );
          return true;
        },
      );
      verbose(
        () => 'copyTree copied: ${truepath(from)} -> ${truepath(to)}, '
            'includeHidden: $includeHidden, recursive: $recursive, '
            'overwrite: $overwrite, includeLinks: $includeLinks',
      );
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CopyTreeException(
        'An error occurred copying directory '
        '${truepath(from)} to ${truepath(to)}. Error: $e',
      );
    }
  }

  void _process(
    String file,
    bool Function(String file) filter,
    String from,
    String to, {
    required bool overwrite,
    required bool recursive,
    required bool includeEmpty,
    required bool includeLinks,
    required bool includeHidden,
  }) {
    if (filter(file)) {
      final target = join(to, relative(file, from: from));

      // If the item is a symbolic link, check its target.
      if (isLink(file)) {
        // If includeLinks is false, skip processing the link.
        if (!includeLinks) return;

        // If the link points to a directory, we want to mimic GNU cp:
        // dereference the link by creating the target directory and
        // recursively copying its contents.
        if (isDirectory(file)) {
          createDir(target, recursive: true);
          copyTree(
            file,
            target,
            overwrite: overwrite,
            includeHidden: includeHidden,
            includeEmpty: includeEmpty,
            includeLinks: includeLinks,
            recursive: recursive,
            filter: filter,
          );
          return;
        }
        // For links to files, let them fall through to file-copying code.
      }

      // If the item is a directory (and not a symlink to a directory),
      // handle empty dirs.
      if (isDirectory(file)) {
        if (includeEmpty && !exists(target)) {
          createDir(target, recursive: true);
        }
        return;
      }

      // For files (or links to files), ensure the parent directory exists.
      if (recursive && !exists(dirname(target))) {
        createDir(dirname(target), recursive: true);
      }

      if (!overwrite && exists(target)) {
        throw CopyTreeException(
          'The target file ${truepath(target)} already exists.',
        );
      }

      // Copy the file (or the dereferenced file from a symlink).
      copy(file, target, overwrite: overwrite);
    }
  }
}

/// Thrown when the [copyTree] function encounters an error.
class CopyTreeException extends DCliFunctionException {
  /// Creates an instance of [CopyTreeException] with [message].
  CopyTreeException(super.message);
}
