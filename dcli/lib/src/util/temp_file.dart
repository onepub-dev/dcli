/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

/// Generates a temporary filename in [pathToTempDir]
/// or if inTempDir os not passed then in
/// the system temp directory.
/// The generated filename is is guaranteed to be globally unique.
///
/// This method does NOT create the file.
///
/// The temp file name will be uuid.tmp
/// unless you provide a [suffix] in which
/// case the file name will be uuid.suffix
String createTempFilename({String? suffix, String? pathToTempDir}) =>
    core.createTempFilename(suffix: suffix, pathToTempDir: pathToTempDir);

/// Generates a temporary filename in the system temp directory
/// that is guaranteed to be unique.
///
/// This method does not create the file.
///
/// The temp file name will be uuid.tmp
/// unless you provide a [suffix] in which
/// case the file name will be uuid.suffix
String createTempFile({String? suffix}) =>
    // ignore: discarded_futures
    core.createTempFile(suffix: suffix);

/// Creates a temp file and then calls [action].
///
///
/// NOTE: DO NOT use this with an async [action]. Instead
/// use dcli_core.withTempFileAsync.
///
/// Once [action] completes the temporary file will be deleted.
///
/// The [action]s return value [R] is returned from the [withTempFile]
/// function.
///
/// If [create] is true (default true) then the temp file will be
/// created. If [create] is false then just the name will be
/// generated.
///
/// if [pathToTempDir] is passed then the file will be created in that
/// directory otherwise the file will be created in the system
/// temp directory.
///
/// The temp file name will be uuid.tmp
/// unless you provide a [suffix] in which
/// case the file name will be uuid.suffix
///
/// NOTE: [action] must NOT be async.
/// @ see core.withTempFile if you meed to use an async action.
R withTempFile<R>(
  R Function(String tempFile) action, {
  String? suffix,
  String? pathToTempDir,
  bool create = true,
  bool keep = false,
}) {
  final tmp = createTempFilename(suffix: suffix, pathToTempDir: pathToTempDir);
  if (create) {
    touch(tmp, create: true);
  }

  R result;
  try {
    result = action(tmp);
  } finally {
    if (exists(tmp) && !keep) {
      delete(tmp);
    }
  }
  return result;
}
