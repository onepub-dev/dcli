/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_common/dcli_common.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart'
    show BackupFileException, RestoreFileException;

/// Provide a very simple mechanism to backup a single file.
///
/// The backup is placed in '.bak' subdirectory under the passed
/// [pathToFile]'s directory.
///
/// Be cautious that you don't nest backups of the same file
/// in your code as we always use the same backup target.
/// Instead use [withFileProtectionAsync].
///
/// We also renamed the backup to `<filename>.bak` to ensure
/// the backupfile doesn't interfere with dev tools
/// (e.g. we don't want an extra pubspec.yaml hanging about)
///
/// If a file at [pathToFile] doesn't exist then a [BackupFileException]
/// is thrown unless you pass the [ignoreMissing] flag.
///
/// See:
///  * [restoreFile]
///  * [withFileProtectionAsync]
///
/// @Throwing(ArgumentError)
/// @Throwing(BackupFileException)
/// @Throwing(CopyException)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteException)
void backupFile(String pathToFile, {bool ignoreMissing = false}) =>
    core.backupFile(pathToFile, ignoreMissing: ignoreMissing);

/// Designed to work with [backupFile] to restore
/// a file from backup.
/// The existing file is deleted and restored
/// from the `.bak/<filename>.bak` file created when
/// you called [backupFile].
///
/// Consider using [withFileProtectionAsync] for a more robust solution.
///
/// When the last .bak file is restored, the .bak directory
/// will be deleted. If you don't restore all files (your app crashes)
/// then a .bak directory and files may be left hanging around and you may
/// need to manually restore these files.
/// If the backup file doesn't exists this function throws
/// a [RestoreFileException] unless you pass the [ignoreMissing]
/// flag.
/// @Throwing(ArgumentError)
/// @Throwing(CopyException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(MoveException)
/// @Throwing(RestoreFileException)
void restoreFile(String pathToFile, {bool ignoreMissing = false}) =>
    core.restoreFile(pathToFile, ignoreMissing: ignoreMissing);

/// Throws [UnsupportedError].
/// @Throwing(UnsupportedError)
@Deprecated('Use withFileProtectionAsync')
R withFileProtection<R>(
  List<String> protected,
  R Function() action, {
  String? workingDirectory,
}) {
  throw UnsupportedError('Use withFileProtectionAsync');
}

/// EXPERIMENTAL - use with caution and the api may change.
///
/// Allows you to nominate a list of files to be backed up
/// before an operation commences
/// and then restored once the operation completes.
///
/// Currently the files a protected by making a copy of each file/directory
/// into a unique system temp directory and then moved back once the
/// [action] has completed.
///
/// NOTE: DO NOT use this with an async [action]. Instead use
/// dcli_core.withFileProtectionAsync.
///
/// [withFileProtectionAsync] is safe to use in a nested fashion as each call
/// to [withFileProtectionAsync] creates its own separate backup area.
///
/// If the VM aborts during execution of the [action] you will find
/// the backed up files in the system temp directory under a directory named
/// .withFileProtection'. You may need to use the time stamp to determine which
/// directory is the right one if you have had mulitple failures.
/// Under normal circumstances the temp directory is delete once the action
/// completes.
///
/// The [protected] list can contain files, directories.
///
/// If the entry is a directory then all children (files and directories)
/// are protected.
///
/// Entries in the [protected] list may be relative or absolute.
///
/// If [protected] contains a file or directory that doesn't exist
/// and the [action] subsequently creates those entities, then those files
/// and/or directories will be deleted after [action] completes.
///
/// This function can be useful for doing dry-run operations
/// where you need to ensure the filesystem is restore to its
/// prior state after the dry-run completes.
///
///
/// Throws [BackupFileException].
/// @Throwing(ArgumentError)
/// @Throwing(core.BackupFileException)
/// @Throwing(CopyException)
/// @Throwing(core.CopyTreeException)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(MoveException)
/// @Throwing(MoveTreeException)
/// @Throwing(core.TouchException)
Future<R> withFileProtectionAsync<R>(
  List<String> protected,
  Future<R> Function() action, {
  String? workingDirectory,
}) async {
  // removed glob support for the moment.
  // This is because if one of the protected entries is missing
  // then we are assuming its a glob.
  // We should probably change to accepting a Pattern
  // and the have the user pass an actual Glob.
  // Problem with this is that find uses a subset of Glob.
  // so for the moment, no glob support
  // a glob pattern as supported by the [find] command.
  // We only support searching for files by the glob pattern (not directories).
  // If the entry is a glob pattern then it is applied recusively.

  final workingDirectory0 = workingDirectory ?? pwd;
  final result = await withTempDirAsync(
    (backupDir) async {
      verbose(() => 'withFileProtection: backing up to $backupDir');

      /// backup the protected files
      /// to a backupDir
      for (final path in protected) {
        final paths = determinePaths(
          path: path,
          workingDirectory: workingDirectory0,
          backupDir: backupDir,
        );

        if (!exists(paths.sourcePath)) {
          /// the file/directory doesn't exist.
          /// During the restore process this path will be deleted
          /// so that once again they don't exist.
          continue;
        }

        if (isFile(paths.sourcePath)) {
          if (!exists(dirname(paths.backupPath))) {
            createDir(dirname(paths.backupPath), recursive: true);
          }

          /// the entity is a simple file.
          copy(paths.sourcePath, paths.backupPath);
        } else if (isDirectory(paths.sourcePath)) {
          /// the entity is a directory so copy the whole tree
          /// recursively.
          if (!exists(paths.backupPath)) {
            createDir(paths.backupPath, recursive: true);
          }
          copyTree(paths.sourcePath, paths.backupPath, includeHidden: true);
        } else {
          throw BackupFileException(
            'Unsupported entity type for ${paths.sourcePath}. '
            'Only files and directories are supported',
          );
        }
        // else {
        //   /// Must be a glob.
        //   for (final file in find(paths.source, includeHidden: true)
        //        .toList()) {
        //     // we need to determine the paths for each [file]
        //     // as the can have a different relative path as we
        //     // do a recursive search.
        //     final paths = _determinePaths(
        //         path: file, sourceDir: sourceDir, backupDir: backupDir);

        //     if (!exists(dirname(paths.target))) {
        //       createDir(dirname(paths.target), recursive: true);
        //     }
        //     copy(paths.source, paths.target);
        //   }
        // }
      }
      final result = await action();

      /// restore the protected entities
      for (final path in protected) {
        final paths = determinePaths(
          path: path,
          workingDirectory: workingDirectory0,
          backupDir: backupDir,
        );
        {
          if (!exists(paths.backupPath)) {
            /// If the protected entity didn't exist before we started
            /// the make certain it doesn't exist now.
            _deleteEntity(paths.sourcePath);
          }

          if (isFile(paths.backupPath)) {
            await _restoreFile(paths);
          }

          if (isDirectory(paths.backupPath)) {
            _restoreDirectory(paths);
          }
        }
      }

      return result;
    },
    keep: true,
  );

  return result;
}

/// @Throwing(ArgumentError)
/// @Throwing(DeleteDirException)
void _deleteEntity(String path) {
  if (isFile(path)) {
    delete(path);
  } else if (isDirectory(path)) {
    deleteDir(path);
  } else {
    verbose(() => 'Path is of unsuported type');
  }
}

/// @Throwing(ArgumentError)
/// @Throwing(CopyException)
/// @Throwing(DeleteException)
/// @Throwing(MoveException)
/// @Throwing(core.TouchException)
Future<void> _restoreFile(Paths paths) async {
  await withTempFileAsync<void>(
    (dotBak) async {
      try {
        if (exists(paths.sourcePath)) {
          move(paths.sourcePath, dotBak);
        }

        // TODO(bsutton): consider only restoring the file if its last modified
        // time has changed.
        move(paths.backupPath, paths.sourcePath);
        if (exists(dotBak)) {
          delete(dotBak);
        }
      } catch (e) {
        /// The restore failed so if the dotBak file
        /// exists lets at least restore that.
        if (exists(dotBak)) {
          /// this should never happen as if we have the dotBak
          /// file then the originalFile should not exists.
          /// but just in case.
          if (exists(paths.sourcePath)) {
            delete(paths.sourcePath);
          }
          move(dotBak, paths.sourcePath);
        }
      }
    },
    create: false,
  );
}

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(MoveTreeException)
void _restoreDirectory(Paths paths) {
  /// For directories we just recreate them if necessary.
  /// This allows us to restore empty directories.
  if (exists(paths.sourcePath)) {
    deleteDir(paths.sourcePath);
  }
  createDir(paths.sourcePath, recursive: true);

  /// The find command will return all of the nested files so
  /// we don't need to restore them when we see the directory.
  moveTree(paths.backupPath, paths.sourcePath, includeHidden: true);
}
