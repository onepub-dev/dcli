/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;

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
/// Instead use [withFileProtection].
///
/// We also renamed the backup to '<filename>.bak' to ensure
/// the backupfile doesn't interfere with dev tools
/// (e.g. we don't want an extra pubspec.yaml hanging about)
///
/// If a file at [pathToFile] doesn't exist then a [BackupFileException]
/// is thrown unless you pass the [ignoreMissing] flag.
///
/// See:
///  * [restoreFile]
///  * [withFileProtection]
///
void backupFile(String pathToFile, {bool ignoreMissing = false}) =>
    // ignore: discarded_futures
    waitForEx(core.backupFile(pathToFile, ignoreMissing: ignoreMissing));

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
void restoreFile(String pathToFile, {bool ignoreMissing = false}) =>
    // ignore: discarded_futures
    waitForEx(core.restoreFile(pathToFile, ignoreMissing: ignoreMissing));

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
R withFileProtection<R>(
  List<String> protected,
  R Function() action, {
  String? workingDirectory,
}) =>
    waitForEx(
      // ignore: discarded_futures
      core.withFileProtection(
        protected,
        action,
        workingDirectory: workingDirectory,
      ),
    );
