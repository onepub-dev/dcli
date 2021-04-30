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
/// We also renamed the backup to '<filename>.bak' to ensure
/// the backupfile doesn't interfere with dev tools
/// (e.g. we don't want an extra pubspec.yaml hanging about)
///
/// See: restoreFile
///
void backupFile(String pathToFile) {
  final pathToBackupFile = _backupFilePath(pathToFile);
  if (exists(pathToBackupFile)) {
    delete(pathToBackupFile);
  }
  createDir(dirname(pathToBackupFile));

  copy(pathToFile, pathToBackupFile);
}

/// Designed to work with [backupFile] to restore
/// a file from backup.
/// The existing file is deleted and restored
/// from the .bak/<filename>.bak file created when
/// you called [backupFile].
///
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
  } else {
    if (ignoreMissing) {
      Settings().verbose('Missing restoreFile $pathToBackupFile ignored');
    } else {
      throw RestoreFileException(
          'The backup file $pathToBackupFile is missing');
    }
  }
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
