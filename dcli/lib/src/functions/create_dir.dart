/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart' show CreateDirException;

/// Creates a directory as described by [path].
/// Path may be a single path segment (e.g. bin)
/// or a full or partial tree (e.g. /usr/bin)
///
/// ```dart
/// createDir("/tmp/fred/tools", recursive: true);
/// ```
///
/// If [recursive] is true then any parent
/// paths that don't exist will be created.
///
/// If [recursive] is false then any parent paths
/// don't exist then a [CreateDirException] will be thrown.
///
/// If the [path] already exists an exception is thrown.
///
/// As a convenience [createDir] returns the same path
/// that it was passed.
///
/// ```dart
///  var path = createDir('/tmp/new_home');
/// ```
///

String createDir(String path, {bool recursive = false}) =>
// ignore: discarded_futures
    waitForEx(core.createDir(path, recursive: recursive));

/// Creates a temp directory and then calls [action].
/// Once action completes the temporary directory will be deleted.
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
R withTempDir<R>(R Function(String tempDir) action,
        {bool keep = false, String? pathToTempDir}) =>
    // ignore: discarded_futures
    waitForEx(core.withTempDir(action, keep: keep));

/// Creates a temporary directory under the system temp folder.
/// The temporary directory name is formed from a uuid.
/// It is your responsiblity to delete the directory once you have
/// finsihed with it.
// ignore: discarded_futures
String createTempDir() => waitForEx(core.createTempDir());
