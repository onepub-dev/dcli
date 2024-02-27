/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' show MoveDirException;

export 'package:dcli_core/dcli_core.dart' show MoveDirException;

/// Moves or renames the [from] directory to the
/// to the [to] path.
///
/// The [to] path must NOT exist.
///
/// The [from] path must be a directory.
///
/// [moveDir] first tries to rename the directory, if that
/// fails due to the [to] path being on a different device
/// we fall back to a copy/delete operation.
///
/// ```dart
/// moveDir("/tmp/", "/tmp/new_dir");
/// ```
///
/// Throws a [MoveDirException] if:
///   the [from] path doesn't exist
///   the [from] path isn't a directory
///   the [to] path already exists.
///
// ignore: discarded_futures
void moveDir(String from, String to) => core.moveDir(from, to);
