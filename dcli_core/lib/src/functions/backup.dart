import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

import '../../dcli_core.dart';
import '../util/logging.dart';

/// Provide a very simple mechanism to backup a single file.
///
/// The backup is placed in '.bak' subdirectory under the passed
/// [pathToFile]'s directory.
///
/// Be cautious that you don't nest backups of the same file
/// in your code as we always use the same backup target.
/// Instead use [withFileProtection].
///
/// We also renamed the backup to '<filename>.bak' to ensure
/// the backupfile doesn't interfere with dev tools
/// (e.g. we don't want an extra pubspec.yaml hanging about)
///
/// If a file at [pathToFile] doesn't exist then a [BackupFileException]
/// is thrown unless you pass the [ignoreMissing] flag.
///
/// See: [restoreFile]
///   [withFileProtection]
///
Future<void> backupFile(String pathToFile, {bool ignoreMissing = false}) async {
  if (!exists(pathToFile)) {
    throw BackupFileException(
      'The backup file ${truepath(pathToFile)} is missing',
    );
  }
  final pathToBackupFile = _backupFilePath(pathToFile);
  if (exists(pathToBackupFile)) {
    await delete(pathToBackupFile);
  }
  if (!exists(dirname(pathToBackupFile))) {
    await createDir(dirname(pathToBackupFile));
  }

  verbose(() => 'Backing up ${truepath(pathToFile)}');
  await copy(pathToFile, pathToBackupFile);
}

/// Designed to work with [backupFile] to restore
/// a file from backup.
/// The existing file is deleted and restored
/// from the .bak/<filename>.bak file created when
/// you called [backupFile].
///
/// Consider using [withFileProtection] for a more robust solution.
///
/// When the last .bak file is restored, the .bak directory
/// will be deleted. If you don't restore all files (your app crashes)
/// then a .bak directory and files may be left hanging around and you may
/// need to manually restore these files.
/// If the backup file doesn't exists this function throws
/// a [RestoreFileException] unless you pass the [ignoreMissing]
/// flag.
Future<void> restoreFile(String pathToFile,
    {bool ignoreMissing = false}) async {
  final pathToBackupFile = _backupFilePath(pathToFile);

  if (exists(pathToBackupFile)) {
    if (exists(pathToFile)) {
      await delete(pathToFile);
    }

    await move(pathToBackupFile, pathToFile);

    if (await isEmpty(dirname(pathToBackupFile))) {
      await deleteDir(dirname(pathToBackupFile));
    }
    verbose(() => 'Restoring  ${truepath(pathToFile)}');
  } else {
    if (ignoreMissing) {
      verbose(
        () => 'Missing restoreFile ${truepath(pathToBackupFile)} ignored.',
      );
    } else {
      throw RestoreFileException(
        'The backup file ${truepath(pathToBackupFile)} is missing',
      );
    }
  }
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

///
/// [withFileProtection] is safe to use in a nested fashion as each call
/// to [withFileProtection] creates its own separate backup area.
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
// ignore: flutter_style_todos
/// TODO: make this work for other than current drive under Windows
///
Future<R> withFileProtection<R>(
  List<String> protected,
  R Function() action, {
  String? workingDirectory,
}) async {
  // removed glob support for the moment.
  // This is because if one of the protected entriese is missing
  // then we are assuming its a glob.
  // We should probably change to accepting a Pattern
  // and the have the user pass an actual Glob.
  // Problem with this is that find uses a subset of Glob.
  // so for the moment, no glob support
  // a glob pattern as supported by the [find] command.
  // We only support searching for files by the glob pattern (not directories).
  // If the entry is a glob pattern then it is applied recusively.

  final _workingDirectory = workingDirectory ?? pwd;
  final result = await withTempDir(
    (backupDir) async {
      verbose(() => 'withFileProtection: backing up to $backupDir');

      /// backup the protected files
      /// to a backupDir
      for (final path in protected) {
        final paths = _determinePaths(
          path: path,
          workingDirectory: _workingDirectory,
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
            await createDir(dirname(paths.backupPath), recursive: true);
          }

          /// the entity is a simple file.
          await copy(paths.sourcePath, paths.backupPath);
        } else if (isDirectory(paths.sourcePath)) {
          /// the entity is a directory so copy the whole tree
          /// recursively.
          if (!exists(paths.backupPath)) {
            await createDir(paths.backupPath, recursive: true);
          }
          await copyTree(paths.sourcePath, paths.backupPath,
              includeHidden: true);
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
      final result = action();

      /// restore the protected entities
      for (final path in protected) {
        final paths = _determinePaths(
          path: path,
          workingDirectory: _workingDirectory,
          backupDir: backupDir,
        );
        {
          if (!exists(paths.backupPath)) {
            /// If the protected entity didn't exist before we started
            /// the make certain it doesn't exist now.
            await _deleteEntity(paths.sourcePath);
          }

          if (isFile(paths.backupPath)) {
            await _restoreFile(paths);
          }

          if (isDirectory(paths.backupPath)) {
            await _restoreDirectory(paths);
          }
        }
      }

      return result;
    },
    keep: true,
  );

  return result;
}

Future<void> _restoreFile(_Paths paths) async {
  await withTempFile(
    (dotBak) async {
      try {
        if (exists(paths.sourcePath)) {
          await move(paths.sourcePath, dotBak);
        }

        // ignore: flutter_style_todos
        /// TODO: consider only restoring the file if its last modified
        /// time has changed.
        await move(paths.backupPath, paths.sourcePath);
        if (exists(dotBak)) {
          await delete(dotBak);
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        /// The restore failed so if the dotBak file
        /// exists lets at least restore that.
        if (exists(dotBak)) {
          /// this should never happen as if we have the dotBak
          /// file then the originalFile should not exists.
          /// but just in case.
          if (exists(paths.sourcePath)) {
            await delete(paths.sourcePath);
          }
          await move(dotBak, paths.sourcePath);
        }
      }
    },
    create: false,
  );
}

Future<void> _restoreDirectory(_Paths paths) async {
  /// For directories we just recreate them if necessary.
  /// This allows us to restore empty directories.
  if (exists(paths.sourcePath)) {
    await deleteDir(paths.sourcePath);
  }
  await createDir(paths.sourcePath, recursive: true);

  /// The find command will return all of the nested files so
  /// we don't need to restore them when we see the directory.
  await moveTree(paths.backupPath, paths.sourcePath, includeHidden: true);
}

Future<void> _deleteEntity(String path) async {
  if (isFile(path)) {
    await delete(path);
  } else if (isDirectory(path)) {
    await deleteDir(path);
  } else {
    verbose(() => 'Path is of unsuported type');
  }
}

/// Determine the paths to the source and backup directories
///
/// [path] is the relative or absolute path to the
/// file that we are going to backup. If [path] is
/// relative then it is relative to [workingDirectory].
/// [backupDir] is the temporary directory that we
/// are going to backup [path] to.
///
/// We use the following directory structure for the backup
/// relative/<path to [path]>
/// absolute/<path to [path]>
///
/// On Windows to accomodate drive letters we need a slightly
/// different directory structure
/// relative/<path to [path]>
/// absolute/<XDrive>/<path to [path]>
///
/// Where 'X' is the drive letter that [path] is located on.
///
_Paths _determinePaths({
  required String path,
  required String workingDirectory,
  required String backupDir,
}) {
  late final String sourcePath;
  late final String backupPath;

  /// we use two different directories for relative and absolute
  /// paths otherwise we can't differentiate when it comes time
  /// to restore.
  if (isRelative(path)) {
    backupPath = truepath(backupDir, 'relative', path);
    sourcePath = join(workingDirectory, path);
  } else {
    sourcePath = truepath(path);
    final translatedPath =
        translateAbsolutePath(path, workingDirectory: workingDirectory);
    backupPath = join(backupDir, 'absolute', _stripRootPrefix(translatedPath));
  }

  return _Paths(sourcePath, backupPath);
}

class _Paths {
  _Paths(this.sourcePath, this.backupPath);

  String sourcePath;
  String backupPath;
}

/// Removes the root prefix (/ or \) from an absolute path
/// If there is no root prefix the original [absolutePath]
/// is returned untouched.
/// If the [absolutePath] only contains the root prefix
/// then a blank string is returned
///
///  /hellow -> hellow
///  hellow -> hellow
///  / ->
///
String? _stripRootPrefix(String absolutePath) {
  if (absolutePath.startsWith(r'\') || absolutePath.startsWith('/')) {
    if (absolutePath.length > 1) {
      return absolutePath.substring(1);
    } else {
      // the path only contained the root prefix and nothing else.
      return '';
    }
  }
  return absolutePath;
}

/// Windows, an absolute path starts with `\\`, or a drive letter followed by
/// `:/` or `:\`.
/// This method will strip the prefix so the path start with a \ or /
/// and the prepend the drive letter so that it becomes a valid
/// path. If the [absolutePath] doesn't contain a drive letter
/// then we take the drive letter from the [workingDirectory].
/// If this is a linux absolute path it is returned unchanged.
///
/// C:/abc -> /CDrive/abc
/// C:\abc -> /CDrive\abc
/// \\\abc -> \abc
/// \\abc -> abc
///
/// The [context] is only used for unit testing so
/// we can fake the platform separator.
@visibleForTesting
String translateAbsolutePath(
  String absolutePath, {
  String? workingDirectory,
  p.Context? context,
}) {
  if (!Platform.isWindows) {
    return absolutePath;
  }

  context ??= p.context;

  // ignore: parameter_assignments
  workingDirectory ??= pwd;

  final parts = context.split(absolutePath);
  if (parts[0].contains(':')) {
    final index = parts[0].indexOf(':');

    final drive = parts[0][index - 1].toUpperCase();
    return context.joinAll(['\\${drive}Drive', ...parts.sublist(1)]);
  }

  if (parts[0].startsWith(r'\\')) {
    final uncparts = parts[0].split(r'\\');
    return context.joinAll([r'\UNC', ...uncparts.sublist(1)]);
  }

  if (absolutePath.startsWith(r'\') || absolutePath.startsWith('/')) {
    String drive;
    if (workingDirectory.contains(':')) {
      drive = workingDirectory[0].toUpperCase();
    } else {
      drive = pwd[0].toUpperCase();
    }
    return context.joinAll(['\\${drive}Drive', ...parts.sublist(1)]);
  }

  /// probably not an absolute path
  /// so just pass back what we were handed.
  return absolutePath;
}

String _backupFilePath(String pathToFile) {
  final sourcePath = dirname(pathToFile);
  final destPath = join(sourcePath, '.bak');
  final filename = basename(pathToFile);

  return '${join(destPath, filename)}.bak';
}

/// Thrown by the [restoreFile] function when
/// the backup file is missing.
class RestoreFileException extends DCliException {
  /// Creates a [RestoreFileException] with the given
  /// message.
  RestoreFileException(String message) : super(message);
}

/// Thrown by the [backupFile] function when
/// the file to be backed up is missing.
class BackupFileException extends DCliException {
  /// Creates a [BackupFileException] with the given
  /// message.
  BackupFileException(String message) : super(message);
}
