import 'package:path/path.dart';

import '../../dcli.dart';
import '../settings.dart';
import 'copy.dart';
import 'delete.dart';
import 'is.dart';
import 'move.dart';

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
void backupFile(String pathToFile, {bool ignoreMissing = false}) {
  if (!exists(pathToFile)) {
    throw BackupFileException(
        'The backup file ${truepath(pathToFile)} is missing');
  }
  final pathToBackupFile = _backupFilePath(pathToFile);
  if (exists(pathToBackupFile)) {
    delete(pathToBackupFile);
  }
  if (!exists(dirname(pathToBackupFile))) {
    createDir(dirname(pathToBackupFile));
  }

  Settings().verbose('Backing up ${truepath(pathToFile)}');
  copy(pathToFile, pathToBackupFile);
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
void restoreFile(String pathToFile, {bool ignoreMissing = false}) {
  final pathToBackupFile = _backupFilePath(pathToFile);

  if (exists(pathToBackupFile)) {
    if (exists(pathToFile)) {
      delete(pathToFile);
    }

    move(pathToBackupFile, pathToFile);

    if (isEmpty(dirname(pathToBackupFile))) {
      deleteDir(dirname(pathToBackupFile));
    }
    Settings().verbose('Restoring  ${truepath(pathToFile)}');
  } else {
    if (ignoreMissing) {
      Settings().verbose(
          'Missing restoreFile ${truepath(pathToBackupFile)} ignored.');
    } else {
      throw RestoreFileException(
          'The backup file ${truepath(pathToBackupFile)} is missing');
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
/// The [protected] list can contain files, directories or
/// a glob pattern as supported by the [find] command.
/// We only support searching for files by the glob pattern (not directories).
///
/// If the entry is a directory then all children (files and directories)
/// are protected.
/// If the entry is a glob pattern then it is applied recusively.
///
/// Entries in the [protected] list may be relative or absolute.
///
///
/// This function can be useful for doing dry-run operations
/// where you need to ensure the filesystem is restore to its
/// prior state after the dry-run completes.
///
// ignore: flutter_style_todos
/// TODO: make this work for other than current drive under Windows
///
R withFileProtection<R>(List<String> protected, R Function() action,
    {String? workingDirectory}) {
  final sourceDir = workingDirectory ?? pwd;
  final result = withTempDir((backupDir) {
    print('backing up to $backupDir');

    /// backup the protected files
    /// to a backupDir
    for (final path in protected) {
      final paths = _determinePaths(
          path: path, sourceDir: sourceDir, backupDir: backupDir);

      if (isFile(paths.source)) {
        if (!exists(dirname(paths.target))) {
          createDir(dirname(paths.target), recursive: true);
        }

        /// the entity is a simple file.
        copy(paths.source, paths.target);
      } else if (isDirectory(paths.source)) {
        /// the entity is a directory so copy the whole tree
        /// recursively.
        if (!exists(paths.target)) {
          createDir(paths.target, recursive: true);
        }
        copyTree(paths.source, paths.target, includeHidden: true);
      } else {
        /// Must be a glob.
        for (final file in find(paths.source, includeHidden: true).toList()) {
          // we need to determine the paths for each [file]
          // as the can have a different relative path as we
          // do a recursive search.
          final paths = _determinePaths(
              path: file, sourceDir: sourceDir, backupDir: backupDir);

          if (!exists(dirname(paths.target))) {
            createDir(dirname(paths.target), recursive: true);
          }
          copy(paths.source, paths.target);
        }
      }
    }
    final result = action();

    /// Find and restore all of the files we backed up.
    for (final file in find('*',
            workingDirectory: backupDir,
            types: [Find.file, Find.directory],
            includeHidden: true)
        .toList()) {
      /// We don't process these top level directories directly
      if (file == join(backupDir, 'absolute') ||
          file == join(backupDir, 'relative')) {
        continue;
      }
      withTempFile((dotBak) {
        final String originalPath;
        final relativeToBackupDir = relative(file, from: backupDir);
        if (relativeToBackupDir.startsWith('absolute')) {
          originalPath =
              '$rootPath${joinAll(split(relativeToBackupDir).sublist(1))}';
        } else {
          originalPath =
              joinAll([sourceDir, ...split(relativeToBackupDir).sublist(1)]);
        }

        /// For directories we just recreate them if necessary.
        /// This allows us to restore empty directories.
        /// The find command will return all of the nested files so
        /// we don't need to restore them when we see the directory.
        if (isDirectory(file)) {
          if (!exists(originalPath)) {
            createDir(originalPath, recursive: true);
          }
          return;
        }
        try {
          if (exists(originalPath)) {
            move(originalPath, dotBak);
          }

          // ignore: flutter_style_todos
          /// TODO: consider only restoring the file if its last modified
          /// time has changed.
          move(file, originalPath);
          if (exists(dotBak)) {
            delete(dotBak);
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          /// The restore failed so if the dotBak file
          /// exists lets at least restore that.
          if (exists(dotBak)) {
            /// this should never happen as if we have the dotBak
            /// file then the originalFile should not exists.
            /// but just in case.
            if (exists(originalPath)) {
              delete(originalPath);
            }
            move(dotBak, originalPath);
          }
        }
      }, create: false);
    }

    return result;
  }, keep: true);

  return result;
}

_Paths _determinePaths(
    {required String path,
    required String sourceDir,
    required String backupDir}) {
  late final String source;
  late final String target;

  /// we use two different directories for relative and absolute
  /// paths otherwise we can't differentiate when it comes time
  /// to restore.
  if (isRelative(path)) {
    target = truepath(backupDir, 'relative', path);
    source = join(sourceDir, path);
  } else {
    // ignore: flutter_style_todos
    /// TODO: make this work for other than current drive under Windows
    source = _stripWindowsAbsolutePrefix(path);
    target = join(backupDir, 'absolute', _stripRootPrefix(source));
  }

  return _Paths(source, target);
}

class _Paths {
  _Paths(this.source, this.target);

  String source;
  String target;
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
/// If this is a linux absolute path it is returned unchanged.
///
/// C:/abc -> /abc
/// C:\abc -> \abc
/// \\\abc -> \abc
/// \\abc -> abc
String _stripWindowsAbsolutePrefix(String absolutePath) {
  final parts = split(absolutePath);
  if (parts[0].contains(':')) {
    return joinAll(parts.sublist(1));
  }

  if (parts[0].startsWith(r'\\')) {
    return joinAll([r'\', ...parts.sublist(1)]);
  }

  /// probably not a windows or not an absolute path
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
