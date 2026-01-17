/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// Creates a temp directory and then calls [action].
/// Once action completes the temporary directory will be deleted.
///
/// NOTE: DO NOT call this with an async [action]. If you do
/// the temporary directory will be deleted whilst the action is running.
/// If you have an async action then use core.withTempDirAsync.
///
/// The actions return value [R] is returned from the [withTempDir]
/// function.
///
/// If you pass [keep] = true then the temp directory won't be deleted.
/// This can be useful when testing and you need to examine the temp directory.
///
/// You can optionally pass in your own tempDir via [pathToTempDir].
/// This can be useful when sometimes you need to control the tempDir
/// and sometimes you want it created.
/// If you pass in [pathToTempDir] it will NOT be deleted regardless
/// of the value of [keep].
/// Throws [UnsupportedError] as method is deprecated.
@Deprecated('Use core.withTempDirAsync as this method is considered unsafe')
R withTempDir<R>(R Function(String tempDir) action,
    {bool keep = false, String? pathToTempDir}) {
  throw UnsupportedError(
      'withTempDir is deprecated. Use core.withTempDirAsync');
}
