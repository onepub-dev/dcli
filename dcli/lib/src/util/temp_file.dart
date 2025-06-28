/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

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
@Deprecated('Use dcli_core.withTempFileAsync instead')
R withTempFile<R>(
  R Function(String tempFile) action, {
  String? suffix,
  String? pathToTempDir,
  bool create = true,
  bool keep = false,
}) {
  throw UnimplementedError('withTempFile has been removed as it is dangerous.');
}
