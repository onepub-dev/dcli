
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
R withFileProtection<R>(List<String> protected, R Function() action) {
  final sourceDir = pwd;
  final result = withTempDir((backupDir) {
    /// backup the protected files
    /// to a backupDir
    for (final path in protected) {
      late final String target;
      if (isRelative(path)) {
        target = truepath(backupDir, relative(path));
      } else {
        target = '$backupDir${_stripWindowsAbsolutePrefix(path)}';
      }
      if (isFile(path)) {
        if (!exists(dirname(target))) {
          createDir(dirname(target), recursive: true);
        }

        /// the entity is a simple file.
        copy(path, target);
      } else if (isDirectory(path)) {
        /// the entity is a directory so copy the whole tree
        /// recursively.
        if (!exists(target)) {
          createDir(target, recursive: true);
        }
        copyTree(path, target);
      } else {
        /// Must be a glob.
        for (final file in find(path, includeHidden: true).toList()) {
          final target = join(backupDir, relative(file));
          if (!exists(dirname(target))) {
            createDir(dirname(target), recursive: true);
          }
          copy(file, target);
        }
      }
    }
    final result = action();

    /// Find and restore all of the files we backed up.
    for (final file
        in find('*', workingDirectory: backupDir, includeHidden: true)
            .toList()) {
      withTempFile((dotBak) {
        final originalFile = relative(file, from: sourceDir);
        try {
          if (exists(originalFile)) {
            move(originalFile, dotBak);
          }
          move(file, originalFile);
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
            if (exists(originalFile)) {
              delete(originalFile);
            }
            move(dotBak, originalFile);
          }
        }
      });
    }

    return result;
  });

  return result;
}

/// Windows, an absolute path starts with `\\`, or a drive letter followed by
/// `:/` or `:\`.
/// This method will strip the prefix so the path start with a \ or /
/// If this is a linux absolute path it is returned unchanged.
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
